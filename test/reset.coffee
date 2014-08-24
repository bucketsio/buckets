mongoose = require 'mongoose'

db = require '../server/lib/database'
config = require '../server/config'
Entry = require '../server/models/entry'

dropDatabase = (done) ->
  db.connection.db.dropDatabase done

prep = (done) ->
  mongoose.connection.on 'connected', done

module.exports =
  db: dropDatabase
  prep: prep
  all: (done) ->
    dropDatabase done
