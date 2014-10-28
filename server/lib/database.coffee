mongoose = require 'mongoose'

logger = require './logger'
config = require '../config'

mongoose.set 'debug', (collection, method, query, doc, options) ->
  logger.verbose '%s#%s'.magenta, collection, method, query, doc, options

module.exports = mongoose.connect config.db
