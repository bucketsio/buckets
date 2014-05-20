Model = require 'lib/model'

module.exports = class User extends Model
  urlRoot: '/api/users'
  