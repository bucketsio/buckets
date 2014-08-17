async = require 'async'

db = require '../server/lib/database'
mongoose = require 'mongoose'
config = require '../server/config'

MongoosasticConfig = require 'mongoosastic/test/config'

dropDatabase = (done) ->
  db.connection.db.dropDatabase done

dropElastic = (done) ->
  MongoosasticConfig.deleteIndexIfExists [config.elasticsearch.index], ->
    setTimeout done, 1100

prep = (done) ->
  mongoose.connection.on 'connected', done

module.exports =
  db: dropDatabase
  prep: prep
  all: (done) ->
    async.parallel [dropElastic, dropDatabase], done
