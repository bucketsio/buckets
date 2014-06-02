mongoose = require 'mongoose'
config = require '../config'

module.exports = mongoose.connect config.db
