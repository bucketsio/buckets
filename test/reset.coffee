db = require '../server/lib/database'
fs = require 'fs-extra'
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
    db.connection.on 'connected', done

module.exports =
  db: dropDatabase
  prep: prep
  all: (done) ->
    dropDatabase done
  builds: (done) ->
    fs.remove config.buildsPath, ->
      fs.ensureDir config.buildsPath, ->
        dropDatabase done
