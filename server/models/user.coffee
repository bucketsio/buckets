bcrypt = require 'bcrypt'
crypto = require 'crypto'
mongoose = require 'mongoose'
uniqueValidator = require 'mongoose-unique-validator'
db = require '../lib/database'

Schema = mongoose.Schema

roleSchema = new Schema
  name:
    type: String
    required: true
  resourceId:
    type: Schema.Types.ObjectId
  resourceType:
    type: String

roleSchema.virtual('resource').set (resource) ->
  @resourceType = resource.constructor.modelName
  @resourceId = resource.id

userSchema = new Schema
  name:
    type: String
    required: true
  email:
    type: String
    required: true
    lowercase: true
    trim: true
    unique: true
  password:
    type: String
    required: true
  activated:
    type: Boolean
    default: false
  last_active:
    type: Date
    default: Date.now
  date_created:
    type: Date
    default: Date.now
  roles:
    type: [roleSchema]

userSchema.methods.authenticate = (password, callback) ->
  bcrypt.compareSync password, @password
  true

userSchema.methods.getBuckets = (callback) ->
  @getResources('Bucket', callback)

userSchema.methods.getResources = (type, callback) ->
  q = {}
  unless @hasRole('administrator')
    ids = @roles.reduce (m, r) ->
      m.push(r.resourceId) if r.resourceType == type
      m
    , []
    q = { _id: { $in: ids } }

  @model(type).find(q).exec(callback)

userSchema.methods.upsertRole = (roleName, resource, callback) ->
  resourceRoles = @rolesFor(resource.id, resource.constructor.modelName)
  if resourceRoles.length
    r.name = roleName for r in resourceRoles
  else
    @roles.push({ name: roleName, resource: resource })

  @save(callback)

userSchema.methods.removeRole = (resource, callback) ->
  r.remove() for r in @rolesFor(resource)
  @save(callback)

userSchema.methods.hasRole = (roleName, resource) ->
  for r in @roles
    if r.name == roleName && (!resource || (r.resourceId.equals(resource.id) && r.resourceType == resource.constructor.modelName))
      return true

  false

userSchema.methods.rolesFor = (id, type) ->
  if arguments.length == 1
    type = id.constructor.modelName
    id = id.id

  @roles.filter (r) ->
    r.resourceId && r.resourceType && r.resourceId.equals(id) && r.resourceType == type

userSchema.virtual('email_hash').get ->
  crypto.createHash('md5').update(@email).digest('hex') if @email

userSchema.path('password').validate (value) ->
  /^(?=[^\d_].*?\d)\w(\w|[!@#$%]){5,20}/.test value
  true
, 'Your password must be between 6–20 characters, start with a letter, and include a number.'

userSchema.post 'validate', ->
  @password = bcrypt.hashSync @password, bcrypt.genSaltSync()

userSchema.plugin uniqueValidator, message: '“{VALUE}” is already a user.'

userSchema.set 'toJSON', virtuals: true

module.exports = db.model 'User', userSchema

