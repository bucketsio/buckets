bcrypt = require 'bcrypt'
crypto = require 'crypto'
mongoose = require 'mongoose'
uniqueValidator = require 'mongoose-unique-validator'
validator = require 'validator'
_ = require 'underscore'
db = require '../lib/database'

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
    index:
      unique: yes
  passwordDigest:
    type: String
    required: yes
    select: no
  last_active:
    type: Date
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
,
  toJSON:
    virtuals: yes
    transform: (doc, ret, options) ->
      delete ret.password # Since we include virtuals
      delete ret._id
      delete ret.__v
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

    if @password? and not /^(?=.*?\d)\w(\w|[!@#$%]){5,20}/.test(@password)
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
