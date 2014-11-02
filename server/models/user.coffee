bcrypt = require 'bcryptjs'
crypto = require 'crypto'
mongoose = require 'mongoose'
uniqueValidator = require 'mongoose-unique-validator'
validator = require 'validator'
dbox = require 'dbox'
async = require 'async'
fs = require 'fs-extra'
_ = require 'underscore'
db = require '../lib/database'

if process.env.DROPBOX_APP_KEY and process.env.DROPBOX_APP_SECRET
  dbox_app = dbox.app
    app_key: process.env.DROPBOX_APP_KEY
    app_secret: process.env.DROPBOX_APP_SECRET

Schema = mongoose.Schema

roleSchema = new Schema
  name:
    type: String
    required: true
  resourceType: String
  resourceId:
    type: Schema.Types.ObjectId
    index: yes

roleSchema.virtual('resource').set (resource) ->
  @resourceId = resource.id
  @resourceType = resource.constructor.modelName

userSchema = new Schema
  name:
    type: String
    required: true
  email:
    type: String
    required: true
    lowercase: true
    trim: true
    unique: yes
  passwordDigest:
    type: String
    required: yes
    select: no
  last_active: Date
  date_created:
    type: Date
    default: Date.now
  roles: [roleSchema]
  resetPasswordToken:
    type: String
    select: no
  resetPasswordExpires:
    type: Date
    select: no
  dropbox: {}
,
  toJSON:
    virtuals: yes
    transform: (doc, ret, options) ->
      delete ret.password # Since we include virtuals
      delete ret._id
      delete ret.__v
      ret.dropbox = true if doc.dropbox?
      ret

userSchema.methods.authenticate = (password) ->
  bcrypt.compareSync password, @passwordDigest if @passwordDigest

userSchema.methods.getBuckets = (callback) ->
  @getResources('Bucket', callback)

userSchema.methods.getResources = (type, callback) ->
  q = {}
  unless @hasRole('administrator')
    ids = _.map @roles, (role) -> role.resourceId if role.resourceType is type
    q = _id: $in: ids
  @model(type).find(q).exec(callback)

userSchema.methods.upsertRole = (roleName, resource, callback) ->
  if (!resource? || _.isFunction(resource))
    @upsertGlobalRole(roleName, resource)
  else
    @upsertScopedRole(roleName, resource, callback)

userSchema.methods.upsertGlobalRole = (roleName, callback) ->
  return callback?(null, @) if @hasRole(roleName)

  @roles.push name: roleName
  @save callback

userSchema.methods.upsertScopedRole = (roleName, resource, callback) ->
  resourceRoles = @getRolesForResource(resource)

  if resourceRoles.length
    r.name = roleName for r in resourceRoles
    @roles = resourceRoles
  else
    @roles.push({ name: roleName, resource: resource })

  @save(callback)

userSchema.methods.removeRole = (resource, callback) ->
  r.remove() for r in @getRoles(resource)
  @save callback

# roleNames can be a String or Array
# Resource can be a String (just a resourceType) or document
userSchema.methods.hasRole = (roleNames, resource) ->
  return true if _.findWhere(@roles, name: 'administrator')

  roles = @getRoles(resource)
  roleNames = if _.isString(roleNames) then [roleNames] else roleNames

  _.any roles, (role) ->
    _.contains(roleNames, role.name)

userSchema.methods.getRoles = (resource) ->
  if resource?._id
    @getRolesForResource resource
  else if _.isString resource
    @getRolesForType resource

userSchema.methods.getRolesForResource = (resource) ->
  @roles.filter (role) ->
    resource._id.equals(role.resourceId)

userSchema.methods.getRolesForType = (resourceType) ->
  @roles.filter (role) ->
    role.resourceType is resourceType or !role.resourceType

userSchema.methods.getDropboxClient = ->
  return no unless dbox_app? and @dropbox?.token and @dropbox?.tokenSecret and @dropbox?.id
  @dropboxClient ?= dbox_app.client
    oauth_token: @dropbox.token
    oauth_token_secret: @dropbox.tokenSecret
    uid: @dropbox.id

# todo: Add websockets or some sort of pubsub to notify user when done
userSchema.methods.initializeDropbox = (host) ->

  initialPath = './deployments/live/'
  client = @getDropboxClient()
  user = @

  return unless client

  copyDir = (path, callback) ->
    console.log 'copying dir', initialPath+path
    fs.readdir initialPath+path, (e, items) ->
      throw e if e
      async.map items, (item, callback) ->
        console.log 'Getting stats for ', path+item
        fs.lstat initialPath+path+item, (e, stats) ->
          throw e if e
          console.log path, item, arguments unless stats
          callback e,
            readPath: path+item
            writePath: host+"/"+path+item
            is_dir: stats.isDirectory()
            is_file: stats.isFile()
      , (e, items) ->
        files = _.where items, is_file: yes
        folders = _.where items, is_dir: yes

        async.parallel [
          (callback) ->
            async.mapLimit files, 4, (file, callback) ->
              fs.readFile initialPath+file.readPath, (e, buffer)->
                return callback(e) if e
                client.put file.writePath, buffer.toString(), (status, reply) ->
                  console.log 'PUT', file.writePath
                  return callback false if status isnt 200
                  callback null, reply
            , callback
        ,
          (callback) ->
            async.mapLimit folders, 2, (folder, callback) ->
              copyDir folder.readPath+"/", callback
            , callback
        ], callback

  copyDir '', (e) ->
    console.error 'There was a problem copying to Dropbox', e if e
    console.log 'Finished copying live to Dropbox'
    # Get the initial cursor
    client.delta (status, reply) ->
      return console.error 'Could’t get the first delta', arguments if status isnt 200 or not reply.cursor
      user.dropbox.cursor = reply.cursor
      user.save()


userSchema.methods.syncDropbox = (host='', reset, callback) ->
  client = @getDropboxClient()
  user = @
  return unless client

  targetDir = @email
  console.log 'Syncing Dropbox for ' + targetDir

  cursor = null
  cursor = @dropbox.cursor unless reset

  client.delta cursor: cursor, (status, reply) ->
    if status isnt 200
      console.log 'Error retrieving Dropbox delta', arguments
      return callback false
    fs.remove "./deployments/#{targetDir}" if reply.reset

    files = []
    folders = []
    removed = []
    for entry in reply.entries
      [path, metadata] = entry

      # Only use items from our targetDir
      continue unless path.indexOf "/#{host}" is 0

      if metadata
        if metadata.is_dir
          folders.push metadata.path # Include caps?
        else
          files.push path
      else
        removed.push path

    console.log 'Syncing updates', files: files, folders: folders, removed: removed

    createPath = (str) -> "./deployments/#{targetDir}" + str.replace("/#{host}", '')

    async.parallel [
      # Add files (limit 4)
      (callback) ->
        async.mapLimit files, 4, (file, callback) ->
          client.get file, (status, reply, metadata) ->
            console.error reply.toString() if status isnt 200
            path = createPath(metadata.path)
            fs.outputFile path, reply.toString(), (e) ->
              console.log 'Wrote file', path
              callback e, metadata
        , callback
    ,
      # Add folders (no limit)
      (callback) ->
        async.map folders, (folder, callback) ->
          fs.ensureDir createPath(folder), callback
        , callback
    ,
      # Remove files (limit 8)
      (callback) ->
        async.map removed, (item, callback) ->
          fs.remove createPath(item)
          console.log 'REMOVING ITEM'
          callback arguments
        , callback

    ], (e, written) ->
      console.error e if e
      return callback e if e

      console.log 'Done syncing Dropbox', arguments
      user.set('dropbox.cursor', reply.cursor)
      user.save ->
        callback e, written
        console.log "Saved new Dropbox cursor for User."

userSchema.virtual 'email_hash'
  .get ->
    crypto.createHash('md5').update(@email).digest('hex') if @email

userSchema.virtual 'password'
  .get -> @_password
  .set (password) ->
    @_password = password
    @passwordDigest = bcrypt.hashSync(password, bcrypt.genSaltSync())

userSchema.path 'passwordDigest'
  .validate (value) ->
    if @isNew and !@password?
      @invalidate 'password', 'A password is required.'

    if @password? and not /^(?=.*?\d)\w(\w|[!@#$%]){5,20}$/.test(@password)
      @invalidate 'password', 'Your password must be between 6–20 characters
        and include a number.'
  , null

userSchema.path 'email'
  .validate (value) ->
    validator.isEmail(value)
  , 'Not a valid email adress'

userSchema.post 'save', ->
  @_password = null

userSchema.plugin uniqueValidator, message: '“{VALUE}” is already a user.'

module.exports = db.model 'User', userSchema
