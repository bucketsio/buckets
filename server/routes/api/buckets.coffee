express = require 'express'

Bucket = require '../../models/bucket'

module.exports = app = express()

app.route('/buckets')
  .post (req, res) ->
    newBucket = new Bucket req.body

    newBucket.save (err, user) ->
      if err
        res.send err, 400
      else if user
        res.send user

  .get (req, res) ->
    Bucket.find {}, (err, buckets) ->
      res.send buckets

app.route('/buckets/:bucketID')
  .delete (req, res) ->
    Bucket.remove _id: req.params.bucketID, (err) ->
      if err
        res.send 400, err
      else
        res.send 200, {}

  .put (req, res) ->
    delete req.body._id
    Bucket.findOneAndUpdate {_id: req.params.bucketID}, req.body, (err, bucket) ->
      if err
        res.send e: err, 400
      else
        res.send bucket, 200
