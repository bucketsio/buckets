Model = require 'lib/model'

module.exports = class PasswordReset extends Model
  urlRoot: '/api/reset'
  idAttribute: 'token'
