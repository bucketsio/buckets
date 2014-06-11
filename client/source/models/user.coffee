_ = require 'underscore'
Model = require 'lib/model'

module.exports = class User extends Model
  urlRoot: '/api/users'
  defaults:
    roles: []

  hasRole: (name, type, id) ->
    _.any @get('roles'), (role) ->
      role.name is name and
        (!type and !id) or
        (!id and role.resourceType is type) or
        (role.resourceType is type and role.resource is id)
