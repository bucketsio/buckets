_ = require 'underscore'
mongoose = require 'mongoose'
async = require 'async'
db = require '../lib/database'
logger = require '../lib/logger'
config = require '../lib/config'
fs = require 'fs-extra'
path = require 'path'
glob = require 'glob'

buildFileSchema = new mongoose.Schema
  filename:
    type: String
    required: true
  contents: String
  date_created:
    type: Date
    default: Date.now
  last_modified:
    type: Date
    default: Date.now
  build_env:
    type: String
    enum: ['staging', 'live']
    default: 'staging'
,
  toJSON:
    virtuals: yes
    transform: (doc, ret, options) ->
      delete ret._id
      delete ret.__v
      ret

buildFileSchema.path('filename').set (newVal) ->
  if @filename? and newVal isnt @filename
    @_removedFile = @filename
  newVal

buildFileSchema.pre 'validate', (next) ->
  cleanFilename = BuildFile.quarantine @filename
  if cleanFilename
    @filename = cleanFilename
  else
    @invalidate 'filename', 'Can’t go above builds directory.'
  next()

buildFileSchema.pre 'save', (next) ->
  if @contents
    logger.verbose 'Writing BuildFile to FS', filename: @filename
    async.parallel [
      (callback) =>
        fs.outputFile "#{config.get('buildsPath')}#{@build_env}/#{@filename}", @contents, callback
    ,
      (callback) =>
        if @_removedFile
          fs.remove "#{config.get('buildsPath')}#{@build_env}/#{@_removedFile}", callback
        else
          callback()
    ], next
  else
    next()

buildFileSchema.statics.quarantine = (filename) ->
  return false unless filename

  try
    realBuildsPath = fs.realpathSync config.get('buildsPath')
    target = path.resolve config.get('buildsPath') + filename
  catch e
    logger.error e

  if target?.indexOf(realBuildsPath) is 0
    target.replace(realBuildsPath, '').replace /^\/*/, ''
  else
    false

# When we delete a file, we remove from fs, then save with contents: null to the DB
# (so we can reconstruct state on startup)
buildFileSchema.statics.rm = (env, filename, callback) ->
  fs.remove fs.realpathSync("#{config.get('buildsPath')}#{env}/#{filename}"), (err) =>
    return callback err if err

    deletedObject =
      filename: filename
      contents: null
      last_modified: Date.now()
      build_env: env

    @update {filename: filename, build_env: env}, deletedObject, upsert: yes, callback

# FS-level search for "editable" text files
buildFileSchema.statics.findAll = (build_env='staging', callback) ->
  filepath = "#{config.get('buildsPath')}#{build_env}"
  return callback?('Build file path doesn’t exist.') unless fs.existsSync filepath

  realpath = fs.realpathSync "#{config.get('buildsPath')}#{build_env}"
  glob '**/*.{hbs,css,js,html,json,jade,eco,styl,scss,sass,md,markdown,coffee}',
    cwd: realpath
    mark: yes
  , (e, items) ->
    return callback e if e
    callback null, ({filename: item, build_env: build_env} for item in items)

# FS-level search for just Handlebars Templates
buildFileSchema.statics.findTemplates = (build_env, callback) ->
  glob '**/*.hbs', cwd: "#{config.get('buildsPath')}#{build_env}/", (e, items) ->
    return callback e if e
    callback null, ({filename: item.replace(/\.hbs$/, '')} for item in items)

module.exports = BuildFile = db.model 'BuildFile', buildFileSchema
