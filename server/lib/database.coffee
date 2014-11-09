mongoose = require 'mongoose'

logger = require './logger'
config = require './config'

mongoose.set 'debug', (collection, method, query, doc, options) ->
  logger.verbose '%s#%s'.magenta, collection, method, query, doc, options

try
  module.exports = mongoose.connect config.get 'db', (err) ->
    logger.error 'Could not connect to MongoDB', connectionString: config.get('db'), error: err
catch err
  logger.error 'Could not connect to MongoDB', connectionString: config.get('db'), error: err
  process.exit()
