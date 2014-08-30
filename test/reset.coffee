async = require 'async'
db = require '../server/lib/database'
mongoose = require 'mongoose'
config = require '../server/config'
buckets = require('../server')
Entry = require '../server/models/entry'

MongoosasticConfig = require 'mongoosastic/test/config'

dropDatabase = (done) ->
  prep ->
    db.connection.db.dropDatabase done

dropIndex = (done) ->
  MongoosasticConfig.deleteIndexIfExists [config.elasticsearch.index], ->
    Entry.createMapping done

prep = (done) ->
  if db.connection.readyState is 1
    done()
  else
    db.connection.on 'connected', ->
      db.connection.db.dropDatabase done

server = (done) ->
  buckets().start done

module.exports =
  db: dropDatabase
  prep: prep
  server: server
  all: (done) ->
    async.parallel [dropIndex, dropDatabase], done
