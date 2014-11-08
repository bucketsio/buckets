mongoose = require 'mongoose'

logger = require './logger'
config = require '../lib/config'

mongoose.set 'debug', (collection, method, query, doc, options) ->
  logger.verbose '%s#%s'.magenta, collection, method, query, doc, options

module.exports = mongoose.connect config.get 'db', (err) ->
  logger.error 'Could not connect to MongoDB', connectionString: config.get('db'), error: err

