_ = require 'underscore'
express = require 'express'
path = require 'path'
async = require 'async'
User = require '../../models/user'
Build = require '../../models/build'
logger = require '../../lib/logger'
fs = require 'fs-extra'

module.exports = app = express()

# Just a proxy for Dropbox#delta
app.get '/builds/staging/checkDropbox', (req, res) ->
  return res.status(401).end() unless req.user?.hasRole ['administrator']

  client = req.user.getDropboxClient()

  return req.status(400).end() unless client

  cursor = req.user.dropbox?.cursor

  client.delta cursor: cursor, (status, reply) ->
    if status is 200 and reply?.entries
      reply.entries = _.reject reply.entries, (entry) -> entry[0].indexOf("/#{req.hostname}") isnt 0
    res.status(status).send(reply)

# This is the same code that called in preview mode
# Except it tells User#syncDropbox to not include a cursor
app.post '/builds/staging/dropbox/import', (req, res, next) ->
  return res.status(401).end() unless req?.user?.hasRole ['administrator']

  req.user.syncDropbox req.hostname, true, (e)->
    console.log 'Done live-syncing Dropbox for preview', arguments
    res.status(200).end()

# Takes the current user’s Dropbox and promotes it to live
app.get '/builds/dropbox', (req, res) ->
  return res.status(401).end() unless req.user?.hasRole ['administrator'] and req.user?.dropbox?.token

  client = req.user.getDropboxClient()
  return res.status(500).end() unless client

  build = new Build
    author: user._id

app.get '/builds', (req, res) ->
  return res.status(401).end() unless req.user?.hasRole ['administrator']

  Build.find().sort('-timestamp').select('-source').populate('author').exec (e, results) ->
    console.error e if e
    res.send results

app.put '/builds/:id', (req, res) ->
  return res.status(401).end() unless req.user?.hasRole ['administrator']
  return res.status(400).end() unless req.body.env in ['staging', 'live']

  Build.findById req.params.id, (e, build) ->
    if e
      logger.error e
      return res.status(500).end()
    else
      return res.status(404).end() unless build

      build.env = req.body.env

      build.save (e, build) ->
        if e
          logger.error e
          res.status(500).end()
        else
          delete build.source
          res.status(200).send build

app.delete '/builds/:id', (req, res) ->
  return res.status(401).end() unless req.user?.hasRole ['administrator']

  Build.findById req.params.id, (e, build) ->
    return res.status(500).end() if e
    return res.status(404).end() unless build
    return res.status(400).send error: 'Only archived builds may be deleted.' if build.env isnt 'archive'

    build.remove (e) ->
      return res.status(500).end() if e
      res.status(204).end()

app.get '/builds/:env(staging|live)/download', (req, res) ->
  return res.status(401).end() unless req.user?.hasRole ['administrator']

  Build.findOne env: req.params.env, (e, build) ->
    return res.status(500).end() if e
    return res.status(404).end() unless build

    build.writeTar (err, filepath) ->
      if err
        logger.error err
        res.status(500).send()
      else
        res.download path.resolve(filepath), "#{build.env}-#{build.id}.tar.gz"

app.get '/builds/:id/download', (req, res) ->
  return res.status(401).end() unless req.user?.hasRole ['administrator']

  Build.findById req.params.id, (e, build) ->
    return res.status(500).end() if e
    return res.status(404).end() unless build

    build.writeTar (err, filepath) ->
      if err
        logger.error err
        res.status(500).send()
      else
        res.download path.resolve(filepath), "#{build.env}-#{build.id}.tar.gz"
