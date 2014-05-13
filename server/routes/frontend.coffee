# Middleware to control the rest of the requests.

# This is temporary—eventually this will be where Buckets routes frontend requests

express = require 'express'

module.exports = app = express()

app.set 'views', "#{__dirname}/../../public"

app.get '/', (req, res) ->
  res.render 'frontend'