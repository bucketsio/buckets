# Middleware to control the rest of the requests.

# This is temporary—eventually this will be where Buckets routes frontend requests
config = require '../config'
express = require 'express'

module.exports = app = express()

app.set 'views', "#{__dirname}/../../user/templates"

app.get '*', (req, res) ->
  res.render 'index',
    adminSegment: config.buckets.adminSegment