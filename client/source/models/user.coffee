_ = require 'underscore'
Model = require 'lib/model'

module.exports = class User extends Model
  urlRoot: '/api/users'
  defaults:
    roles: []

  hasRole: (name, id, type) ->
    _.any @get('roles'), (role) ->
      return yes if role.name is 'administrator'
      
      role.name is name and (
        (!id and role.resourceType is type) or
        (role.resourceId is id)
      )
