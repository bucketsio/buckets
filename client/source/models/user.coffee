_ = require 'underscore'
Model = require 'lib/model'

module.exports = class User extends Model
  urlRoot: '/api/users'

  hasRole: (name, type, id) ->
    _.any @get('roles'), (r) ->
      r.name == name && ((!type && !id) || (r.resourceType == type && r.resourceId == id))

