db = require '../server/lib/database'
config = require '../server/config'
buckets = require('../server')
Entry = require '../server/models/entry'

dropDatabase = (done) ->
  prep ->
    db.connection.db.dropDatabase done

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
    dropDatabase done
