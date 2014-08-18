async = require 'async'

db = require '../server/lib/database'
mongoose = require 'mongoose'
config = require '../server/config'
Entry = require '../server/models/entry'

MongoosasticConfig = require 'mongoosastic/test/config'

dropDatabase = (done) ->
  db.connection.db.dropDatabase done

dropIndex = (done) ->
  MongoosasticConfig.deleteIndexIfExists [config.elasticsearch.index], ->
    Entry.createMapping done

prep = (done) ->
  mongoose.connection.on 'connected', done

module.exports =
  db: dropDatabase
  prep: prep
  all: (done) ->
    async.parallel [dropIndex, dropDatabase], done
