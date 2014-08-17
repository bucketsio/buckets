db = require '../server/lib/database'
config = require '../server/config'

MongoosasticConfig = require 'mongoosastic/test/config'

module.exports = (done) ->
  db.connection.db.dropDatabase()
  MongoosasticConfig.deleteIndexIfExists [config.elasticsearch.index], done
