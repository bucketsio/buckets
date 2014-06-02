Collection = require 'lib/collection'
User = require 'models/user'

module.exports = class Users extends Collection
  url: '/api/users/'
  model: User
