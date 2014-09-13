express = require 'express'
async = require 'async'
_ = require 'underscore'

config = require '../../config'

Bucket = require '../../models/bucket'
Entry = require '../../models/entry'
Route = require '../../models/route'
Template = require('../../lib/template')(config?.templatePath)
User = require '../../models/user'

module.exports = app = express()

app.get '/export', (req, res, next) ->
  res.status(401).end() unless req.user?.hasRole ['administrator']

  async.parallel [
    (cb) ->
      Bucket.find {}, '-fields.id', (e, buckets) ->
        ids = _.pluck buckets, 'id'
        async.map buckets, (bucket, callback) ->
          bkt = bucket.toJSON()
          Entry.find bucket: bkt.id, '-lastModified', (e, entries) ->
            bkt.entries = []
            for entry in entries
              newEntry = entry.toJSON()
              bkt.entries.push entry.toJSON()

            callback e, bkt
        , cb
    , (cb) ->
      Route.find {}, cb
    , (cb) ->
      Template.find cb
  ], (e, results) ->
    return res.status(400).send e if e

    now = new Date()
    res.attachment("buckets-#{now.toISOString()}.json").send
      buckets: results[0]
      routes: results[1]
      templates: results[2]

# app.post '/import', ->

