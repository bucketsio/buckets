express = require 'express'

Bucket = require '../../models/bucket'
User = require '../../models/user'

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
    return res.send(401) unless req.user

    req.user.getBuckets (e, buckets) ->
      res.send 200, buckets

app.route('/buckets/:bucketID')
  .delete (req, res) ->
    Bucket.findOne _id: req.params.bucketID, (err, bkt) ->
      if err
        res.send 400, err
      else
        bkt.remove (err, count) ->
          if err
            res.send 400, err
          else
            res.send 200, {}

  .put (req, res) ->
    delete req.body._id
    Bucket.findOne {_id: req.params.bucketID}, (err, bucket) ->
      return res.send 400, e: err if err
      bucket.set(req.body).save (err, bucket) ->
        return res.send 400, err if err
        res.send 200, bucket

app.route('/buckets/:bucketId/members')
  .get (req, res) ->
    return res.send(401) unless req.user?.hasRole 'administrator'

    Bucket.findById req.params.bucketId, (err, bucket) ->
      return res.send(e: err, 400) if err
      return res.send(404) unless bucket

      bucket.getMembers (err, users) ->
        return res.send(e: err, 400) if err

        users = users.map (user) ->
          u = user.toJSON()
          u.role = user.getRolesForResource(bucket)[0].name
          u.bucketId = req.params.bucketId
          u

        res.send users, 200

app.route('/buckets/:bucketId/members/:userId')
  .put (req, res) ->
    return res.send(401) unless req.user?.hasRole 'administrator'

    Bucket.findById req.params.bucketId, (err, bucket) ->
      return res.send(e: err, 400) if err
      return res.send(404) unless bucket

      User.findById req.params.userId, (err, user) ->
        return res.send(e: err, 400) if err
        return res.send(404) unless user

        user.upsertRole req.body.role, bucket, (err, user) ->
          return res.send(e: err, 400) if err

          u = user.toJSON()
          u.role = req.body.role
          u.bucketId = req.params.bucketId

          res.send u, 200

  .delete (req, res) ->
    return res.send(401) if !req.user || !req.user.hasRole('administrator')

    Bucket.findById req.params.bucketId, (err, bucket) ->
      return res.send(e: err, 400) if err
      return res.send(404) unless bucket

      User.findById req.params.userId, (err, user) ->
        return res.send(e: err, 400) if err
        return res.send(404) unless user

        user.removeRole bucket, (err, user) ->
          return res.send(e: err, 400) if err

          res.send 204

