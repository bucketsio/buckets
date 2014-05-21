db = require '../lib/db'
crypto = require 'crypto'

module.exports = User = db.createModel 'User',
    name: String
    email: String
    password: String