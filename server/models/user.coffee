bcrypt = require 'bcrypt'
crypto = require 'crypto'
mongoose = require 'mongoose'
uniqueValidator = require 'mongoose-unique-validator'
_ = require 'underscore'
db = require '../lib/database'

Schema = mongoose.Schema

roleSchema = new Schema
  name:
    type: String
    required: true
  resourceType: String
  resourceId: Schema.Types.ObjectId

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
  roles: [roleSchema]

userSchema.methods.authenticate = (password, callback) ->
  bcrypt.compareSync password, @password

userSchema.methods.getBuckets = (callback) ->
  @getResources('Bucket', callback)

userSchema.methods.getResources = (type, callback) ->
  q = {}
  unless @hasRole('administrator')
    ids = _.map @roles, (role) -> role.resourceId if role.resourceType is type
    q = _id: $in: ids
  @model(type).find(q).exec(callback)

userSchema.methods.upsertRole = (roleName, resource, callback) ->

  resourceRoles = @getRolesForModel resource

  if resourceRoles.length
    r.name = roleName for r in resourceRoles
    @roles = resourceRoles
  else
    @roles.push name: roleName, resource: resource

  @save callback

userSchema.methods.removeRole = (resource, callback) ->
  r.remove() for r in @getRoles(resource)
  @save callback

# roleNames can be a String or Array
# Resource can be a String (just a resourceType) or document

userSchema.methods.hasRole = (roleNames, resource) ->
  return true if _.findWhere @roles, name: 'administrator'

  roles = @getRoles resource

  if _.isString roleNames
    _.findWhere roles, name: roleNames
  else if _.isArray roleNames
    _.where( roles, (role) ->
        role.name in roleNames
    ).length > 0

userSchema.methods.getRoles = (resource) ->
  if resource?._id
    @getRolesForModel resource
  else if _.isString resource
    @getRolesForType resource

userSchema.methods.getRolesForModel = (resource) ->
  @roles.filter (role) ->
    role.name if role.resourceId is resource._id or !role.resourceId

userSchema.methods.getRolesForType = (resourceType) ->
  @roles.filter (role) ->
    role.resourceType is resourceType or !role.resourceType

userSchema.virtual('email_hash').get ->
  crypto.createHash('md5').update(@email).digest('hex') if @email

userSchema.path('password').validate (value) ->
  /^(?=[^\d_].*?\d)\w(\w|[!@#$%]){5,20}/.test value
, 'Your password must be between 6–20 characters, start with a letter, and include a number.'

userSchema.post 'validate', ->
  @password = bcrypt.hashSync @password, bcrypt.genSaltSync()

userSchema.plugin uniqueValidator, message: '“{VALUE}” is already a user.'

userSchema.set 'toJSON', virtuals: true

module.exports = db.model 'User', userSchema
