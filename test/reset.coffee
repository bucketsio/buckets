db = require '../server/lib/database'
fs = require 'fs-extra'
config = require '../server/config'
buckets = require('../server')
Entry = require '../server/models/entry'
logger = require '../server/lib/logger'

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
    fs.remove config.buildsPath, (e) ->
      logger.error e if e
      fs.ensureDir config.buildsPath, (e) ->
        logger.error e if e
        dropDatabase done
