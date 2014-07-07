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
  passwordDigest:
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
  resetPasswordToken: String
  resetPasswordExpires: Date

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

  @roles.push({ name: roleName })
  @save(callback)

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

userSchema.virtual('email_hash').get ->
  crypto.createHash('md5').update(@email).digest('hex') if @email

passwordVirtual = userSchema.virtual('password')

passwordVirtual.get ->
  @_password

passwordVirtual.set (password) ->
  @_password = password
  @passwordDigest = bcrypt.hashSync(password, bcrypt.genSaltSync())

userSchema.path('passwordDigest').validate (value) ->
  if (@isNew && !@password?)
    @invalidate('password', 'Password is required')

  if @password? && !/^(?=.*?\d)\w(\w|[!@#$%]){5,20}/.test(@password)
    @invalidate('password', 'Your password must be between 6–20 characters and include a number')
, null

userSchema.post 'save', ->
  @_password = null

userSchema.plugin uniqueValidator, message: '“{VALUE}” is already a user.'

userSchema.set 'toJSON', virtuals: true

module.exports = db.model 'User', userSchema
