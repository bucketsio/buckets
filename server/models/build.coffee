mongoose = require 'mongoose'
db = require '../lib/database'
archiver = require 'archiver'
async = require 'async'
fs = require 'fs-extra'
path = require 'path'
filesize = require 'filesize'
crypto = require 'crypto'
tarball = require 'tarball-extract'
uniqueValidator = require 'mongoose-unique-validator'
config = require '../config'
logger = require '../lib/logger'

buildSchema = new mongoose.Schema
  message: String
  author:
    type: mongoose.Schema.Types.ObjectId
    ref: 'User'
  timestamp:
    type: Date
    default: Date.now
    index: yes
  dropbox: {}
  label: String
  source:
    type: Buffer
    required: yes
  env:
    type: String
    enum: ['live', 'staging', 'archive']
    required: yes
  md5:
    type: String
    required: yes
  size: Number
  niceSize: String
,
  toJSON:
    virtuals: yes
    transform: (doc, ret, options) ->
      delete ret._id
      delete ret.__v
      ret

buildSchema.path('env').set (newVal) ->
  @_fromEnv = @env
  newVal

# todo: Switch to GridFS and stream to it directly (as opposed to saving/deleting zip...)
buildSchema.pre 'validate', (next) ->
  @_blend = yes

  # Only generate the zip when it’s not there and we’re saving live or staging
  if (@source and @_fromEnv not in ['live', 'staging']) or !@env
    return next()

  # We need to re-create the .tar.gz
  target = @_fromEnv || @env # Either live or staging

  logger.verbose "Building tar from #{target}"

  dirpath = path.resolve config.buildsPath, target

  Build.generateTar dirpath, (e, tar) =>
    if e?
      logger.error 'Error generating the tar', path: dirpath
      console.log e
      @invalidate 'source', 'Buckets wasn’t able to compress the source.'
      next()
    else
      Build.count {env: @env, md5: tar.md5}, (err, count) =>
        logger.warn 'Found a matching md5, invalidating build.'
        if count is 0
          @set tar
        else
          @invalidate 'source', 'A build with that md5 already exists.'
        next()


buildSchema.pre 'save', (next) ->
  @timestamp = Date.now()
  env = @env
  fromEnv = @_fromEnv || env
  id = @id

  return next() unless env in ['live', 'staging'] and fromEnv isnt env


  if fromEnv is 'staging' and env is 'live'
    @message = 'Published from staging'

  async.parallel [
    (callback) =>
      if fromEnv is 'staging' and env is 'live'
        newStagingData = @toJSON()
        newStagingData.env = 'staging'
        newStagingData.message = 'Copied from live'
        newStagingData.copied = yes
        delete newStagingData._id

        Build.create newStagingData, (err, build) ->
          if err
            logger.error 'Trouble saving the copied live to staging', err: err
          else
            logger.verbose 'Cloned a new live build to staging.'
          callback arguments...
      else
        callback()
  ,
    (callback) ->
      return callback() unless fromEnv isnt 'archive'

      # Clear BuildFiles for this env
      logger.verbose 'Clearing %s buildfile(s)', fromEnv
      mongoose.model('BuildFile').remove build_env: fromEnv, callback
  ,
    (callback) =>
      return callback() if fromEnv is 'staging' and env is 'staging'

      logger.verbose "Looking for other #{env} builds to archive.", env: env, id: @id, md5: @md5
      Build.find {env: env, md5: $ne: @md5}, (e, builds) ->
        logger.verbose 'Found %d builds to archive', builds.length

        async.map builds, (build) ->
          callback() if build.id is id
          logger.verbose "Backing up from #{build.env}", id: id, buildId: build.id
          build.message = "Backed up from #{build.env}"
          build.env = 'archive'
          build.save ->
            logger.verbose "Archived #{build.id} from #{env}"
            callback arguments...
        , callback
  ], =>
    logger.verbose 'Scanning for archives with matching md5s', md5: @md5

    if env is 'live'
      logger.info 'Preparing a new live build'
      @unpack next
    else
      next()

buildSchema.post 'save', ->
  # Build.remove {md5: @md5, env: @env, _id: $ne: @id}, (e, count) =>
  #   logger.verbose 'Build#postSave: Removed %d duplicate build(s) (based on md5)', count, env: @env, md5: @md5

buildSchema.statics.scaffold = (env, callback) ->
  return callback 'Invalid env' unless env in ['live', 'staging']

  # We simultaneously look in the DB and check the FS
  exists = fs.existsSync "#{config.buildsPath}#{env}"

  Build.findOne env: env, (err, build) ->
    return callback err if err

    createNew = (msg, callback) ->
      build = new Build
        env: env
        message: msg
      build.save callback

    if exists
      # If a directory exists, attempt to create a new build out of it
      logger.verbose 'Scaffold: Folder detected, creating build.'
      createNew 'Build created from new local files.', callback
    else
      logger.verbose 'Scaffold: No directory, copying from base.'
      logger.info 'No existing directory, creating %s from base.', env

      fs.removeSync "#{config.buildsPath}#{env}"

      fs.copy "./server/lib/skeletons/base/", "#{config.buildsPath}#{env}", ->
        createNew 'Scaffolded from base.', (e, build) ->
          if build
            logger.verbose 'Created a new build', build.id
            callback null, build
          else
            logger.warn 'Did not create the build', arguments
            callback false

# Writes a deployment to live
# (service agnostic at this point)
buildSchema.methods.unpack = (callback) ->
  if @source and @env
    env = @env
    id = @id

    # Write the .tar.gz to the filesystem
    @writeTar (e, tarPath) =>
      if e
        logger.error e
        return callback no

      logger.verbose "Unpacking #{tarPath} to #{env}"
      async.series [
        # First, write the files from DB .tar.gz
        (callback) ->
          destination = if env is 'staging' then env else id
          finalDestination = path.resolve config.buildsPath, destination

          logger.verbose "Extracting tarball",
            from: tarPath
            to: finalDestination
          logger.profile "Extracted tar.gz to #{destination}"
          tarball.extractTarball tarPath, finalDestination, ->
            logger.profile "Extracted tar.gz for #{destination}"
            callback arguments...
            fs.remove tarPath, -> logger.verbose "Cleaning up #{id}.tar.gz"
      ,
        (callback) => @unpackBuildFiles callback
      ,
        (callback) =>
          async.parallel [
            (callback) ->
              if env is 'live'
                logger.verbose "Rebuilding Symlink, #{env} » #{id}"
                liveSlPath = "#{config.buildsPath}live"
                fs.remove liveSlPath, ->
                  fs.symlink fs.realpathSync("#{config.buildsPath}#{id}"), liveSlPath, 'dir', ->
                    logger.profile "Rebuilding Symlink, #{env} » #{id}"
                    callback arguments...
              else
                callback()
          ,
            (callback) ->
              fs.remove tarPath, callback
          ], callback
      ], callback
  else
    logger.error 'Attempt to unpack a build without a source.'
    callback false

buildSchema.methods.unpackBuildFiles = (callback) ->
  mongoose.model('BuildFile').find build_env: @env, (e, buildfiles) ->
    async.map buildfiles, (buildfile, cb) ->
      filePath = "#{config.buildsPath}#{buildfile.build_env}/#{buildfile.filename}"
      if buildfile.contents is null
        logger.info 'Deleting %s from %s', buildfile.filename, buildfile.build_env
        fs.remove filePath, cb
      else
        logger.info 'Writing %s to %s', buildfile.filename, buildfile.build_env
        fs.outputFile filePath, buildfile.contents, cb
    , callback

buildSchema.methods.getTarPath = ->
  path.resolve "#{config.buildsPath}#{@id}.tar.gz"

buildSchema.methods.writeTar = (callback) ->
  logger.verbose "Writing #{@id}.tar.gz from database (to #{@env})"
  tarPath = @getTarPath()

  fs.outputFile tarPath, @source.toObject()?.buffer, (e) ->
    if e
      callback e
    else
      callback null, tarPath

buildSchema.statics.generateTar = (dirpath, callback) ->
  logger.verbose "Generating tar", path: dirpath

  fs.exists dirpath, (exists) =>

    return callback(new Error 'Directory doesn’t exist.') unless exists

    # Generate the source, md5, size, and niceSize
    time = new Date().toISOString().replace(/\:/g, '.')
    filename = "#{path.basename(dirpath)}.tar.gz"
    tarPath = config.buildsPath + filename
    tarInfo = {}

    md5hash = crypto.createHash 'md5'
    md5hash.setEncoding 'hex'

    logger.verbose 'Writing %s.', filename
    output = fs.createWriteStream tarPath
    output.on 'error', ->
      logger.error 'Error writing .tar.gz'
      return

    output.on 'close', =>
      size = archive.pointer()

      logger.verbose 'Wrote', filename, filesize size

      if size > 15000000 # Cap at 15mb for now

        return callback(new Error 'File size too big')

      md5hash.end()
      fs.readFile tarPath, (err, buffer) ->
        if err
          logger.error 'Could not read the file', error: err
          return callback err
        tarInfo.source = buffer
        tarInfo.md5 = md5hash.read()
        tarInfo.size = size
        tarInfo.niceSize = filesize size

        # Move on to return response
        callback null, tarInfo

        # Then delete the compressed version
        logger.verbose 'Removing tar', path: tarPath
        fs.remove tarPath

    archive = archiver.create 'tar',
      name: '' # Required so md5s don’t include timestamps (just match on contents)
      gzip: yes
      gzipOptions:
        level: 9
    archive.on 'error', (err) ->
      logger.error 'Error creating the build tar.gz.', err
      callback(new Error 'Error generating the tar.gz')
    archive.pipe output
    archive.pipe md5hash

    archive.bulk
      expand: yes
      cwd: fs.realpathSync(dirpath)
      src: ['**']
    archive.finalize()

buildSchema.methods.cleanup = (callback) ->
  dirpath = if @env is 'staging' then @env else @id
  logger.info 'Attempting to delete ', dirpath
  if fs.existsSync "#{config.buildsPath}#{dirpath}"
    fs.remove "#{config.buildsPath}#{dirpath}", callback
  else
    logger.warn 'Build directory doesn’t exist.', dirpath
    callback new Error 'Build directory doesn’t exist.'

buildSchema.statics.getLive = (callback) ->
  @findOne env: 'live', callback

buildSchema.statics.getStaging = (callback) ->
  @findOne env: 'staging', callback

buildSchema.plugin uniqueValidator

module.exports = Build = db.model 'Build', buildSchema
