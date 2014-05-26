express = require 'express'

module.exports = app = express()

app.route('/templates')
  .post (req, res) ->
    res.send 500
  .get (req, res) ->
    res.send []