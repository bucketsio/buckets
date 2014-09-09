express = require 'express'
hbs = require 'hbs'
config = require '../../config'

Template = require('../../lib/template')(config?.templatePath)

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

app.route('/templates')
  .get (req, res) ->
    Template.find (err, files) ->
      if err
        res.status(500).send err
      else
        res.send(files)

  .post (req, res) ->
    errors = validateTemplate req.body.contents
    return res.status(400).send errors if errors

    {filename, contents} = req.body

    Template.write filename, contents, (err) ->
      if err
        res.status(500).send err
      else
        res.status(201).send
          filename: filename
          contents: contents

app.route('/templates/:filename')
  .get (req, res) ->
    Template.read req.params.filename, (err, contents) ->
      if err
        if err.code is 'ENOENT'
          res.status(404).send err
        else
          res.status(500).send err
      else
        res.send filename: req.params.filename, contents: contents

  .delete (req, res) ->
    return res.status(400).send {error: 'Can’t mess with the index yet.'} if req.params.filename is 'index'
    Template.remove req.params.filename, (err) ->
      if err
        res.status(500).send err
      else
        res.status(204).end()

  # not a valid PUT request
  .put (req, res) ->

    errors = validateTemplate req.body.contents
    return res.status(400).send errors if errors

    Template.write [req.params.filename, req.body.filename], req.body.contents, (err) ->
      filename = req.params.filename
      contents = req.body.contents
      if err
        res.status(500).send err
      else
        hbs.cache = {} # Reset hbs internal cache
        res.status(201).send
          filename: filename
          contents: contents
