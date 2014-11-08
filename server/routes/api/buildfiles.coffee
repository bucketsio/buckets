express = require 'express'
hbs = require 'hbs'
config = require '../../lib/config'
logger = require '../../lib/logger'
BuildFile = require '../../models/buildfile'
fs = require 'fs-extra'

module.exports = app = express()

validateTemplate = (contents) ->
  compiler = hbs.create().handlebars
  compiled = compiler.compile contents

  try
    null if compiled {}
  catch e
    lineNum = e.message.match(/^Parse error on line (\d+)/)?[1]
    return errors:
      contents:
        path: 'contents'
        message: e.message
        line: parseInt(lineNum) if lineNum

app.all '/buildfiles/:env*', (req, res, next) ->
  req.params.env = null unless req.params.env in ['live', 'staging']
  next()

app.get '/buildfiles/:env?', (req, res) ->
  return res.status(401).end() unless req.user?.hasRole ['administrator']

  if req.query.type is 'template'
    BuildFile.findTemplates req.params.env, (err, files) ->
      logger.verbose 'Finished finding BuildFiles', files
      if err
        logger.error err
        res.status(500).send err
      else
        res.send files
  else
    BuildFile.findAll req.params.env, (err, files) ->
      logger.verbose 'Finished finding BuildFiles', files
      if err
        logger.error err
        res.status(500).send err
      else
        res.send files

app.all '/buildfiles/:env/:filename', (req, res, next) ->
  return res.status(401).end() unless req.user?.hasRole ['administrator']
  return res.status(403).end() unless BuildFile.quarantine(req.params.filename)
  next()

app.route('/buildfiles/:env/:filename')
  .get (req, res) ->
    return res.status(400).end() unless req.params.env

    path = "#{config.get('buildsPath')}#{req.params.env}/#{req.params.filename}"

    # Return from DB first if available
    fs.exists path, (exists) ->
      return res.status(404).end() unless exists

      fs.readFile path, (e, buffer) ->
        logger.error e if e
        return res.status(500).send(e) if e

        res.send
          filename: req.params.filename
          contents: buffer?.toString()

  .delete (req, res) ->
    BuildFile.rm req.params.env, req.params.filename, (err, buildfile) ->
      return res.status(500).end() if err
      res.status(204).end()

  .put (req, res) ->
    if req.params.filename.match /\.hbs$/
      errors = validateTemplate req.body.contents
      return res.status(400).send errors if errors

    BuildFile.findOne
      filename: req.params.filename
      build_env: req.params.env
    , (e, buildfile) ->
      return res.status(500).end() if e

      buildfile ?= new BuildFile
      buildfile.set
        filename: req.body.filename or req.params.filename # Allow moving
        contents: req.body.contents
        build_env: req.params.env

      buildfile.save (e, buildfile) ->
        if e
          logger.error e
          res.status(400).end()
        else
          res.send buildfile
