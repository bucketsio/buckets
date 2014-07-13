express = require 'express'
config = require '../../config'
Template = require('../../lib/template')(config.buckets?.templatePath)

module.exports = app = express()

app.route('/templates')
  .get (req, res) ->
    Template.find (err, files) ->
      if err
        res.send 500, err
      else
        res.send files

  .post (req, res) ->
    Template.write req.body.filename, req.body.contents, (err) ->
      if err
        res.send 500, err
      else
        res.send 201, {}

app.route('/templates/:filename')
  .get (req, res) ->
    Template.read req.params.filename, (err, contents) ->
      if err
        if err.code is 'ENOENT'
          res.send 404, err
        else
          res.send 500, err
      else
        res.send filename: req.params.filename, contents: contents

  .delete (req, res) ->
    return res.send 400, {error: 'Can’t mess with the index yet.'} if req.params.filename is 'index'
    Template.remove req.params.filename, (err) ->
      if err
        res.send 500, err
      else
        res.send 204

  # not a valid PUT request
  .put (req, res) ->
    Template.write [req.params.filename, req.body.filename], req.body.contents, (err) ->
      if err
        res.send 500, err
      else
        res.send 201, {}
