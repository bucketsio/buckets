db = require '../lib/db'
validator = require 'validator'
bcrypt = require 'bcrypt'

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

  return errors if errors

User.define 'checkPassword', (password) ->
  bcrypt.compareSync password, @password

User.docAddListener 'saving', (doc) ->
  salt = bcrypt.genSaltSync()
  doc.password = bcrypt.hashSync doc.password, salt