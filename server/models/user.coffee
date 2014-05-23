db = require '../lib/db'
validator = require 'validator'

module.exports = User = db.createModel 'User',
    name:
      _type: String
      enforce_missing: yes
    email: String
    password: 
      _type: String
      enforce_missing: yes

User.define 'checkValid', ->
  errors = []
  errors.push 'email' unless validator.isEmail @email
  errors.push 'name' unless @name?.length > 1
  errors.push 'password' unless @password?.length > 1

  true

User.define 'checkPassword', (password) ->
  password is @password