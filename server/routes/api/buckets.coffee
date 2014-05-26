express = require 'express'

Bucket = require '../../models/bucket'

module.exports = app = express()

app.route('/buckets')
  .post (req, res) ->
    newUser = new Bucket req.body
    
    if newUser.checkValid()
      newUser.save().then (user) ->
        res.send user

  .get (req, res) ->

    Bucket.filter({}).run().then (buckets) ->
      res.send buckets