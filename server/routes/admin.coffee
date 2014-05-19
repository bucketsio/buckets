express = require 'express'
module.exports = app = express()

config = require '../config'

app.set 'views', "#{__dirname}/../../public"

app.use express.static '#{__dirname}/../public/'

app.locals.adminSegment = config.buckets.adminSegment

app.all '*', (req, res) ->
  res.render 'admin'

  # This will be where general admin auth goes