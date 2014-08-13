express = require 'express'

Bucket = require '../../models/bucket'
User = require '../../models/user'

module.exports = app = express()

app.route('/buckets')
  .post (req, res) ->
    newBucket = new Bucket req.body

    newBucket.save (err, bucket) ->
      if err
        res.status(400).send err
      else if bucket
        res.status(200).send bucket

  .get (req, res) ->
    return res.status(401).end() unless req.user

    req.user.getBuckets (e, buckets) ->
      res.status(200).send buckets

app.route('/buckets/:bucketID')
  .delete (req, res) ->
    Bucket.findOne _id: req.params.bucketID, (err, bkt) ->
      if err
        res.send 400, err
      else
        bkt.remove (err) ->
          if err
            res.status(400).send err
          else
            res.status(204).end()

  .put (req, res) ->
    delete req.body._id
    Bucket.findOne {_id: req.params.bucketID}, (err, bucket) ->
      return res.status(400).send e: err if err
      bucket.set(req.body).save (err, bucket) ->
        return res.status(400).send err if err
        res.status(200).send bucket

app.route('/buckets/:bucketId/members')
  .get (req, res) ->
    return res.status(401).end() unless req.user?.hasRole 'administrator'

    Bucket.findById req.params.bucketId, (err, bucket) ->
      return res.status(400).send(e: err) if err
      return res.status(404).end() unless bucket

      bucket.getMembers (err, users) ->
        return res.status(400).send(e: err) if err

        users = users.map (user) ->
          u = user.toJSON()
          u.role = user.getRolesForResource(bucket)[0].name
          u.bucketId = req.params.bucketId
          u

        res.status(200).send users

app.route('/buckets/:bucketId/members/:userId')
  .put (req, res) ->
    return res.status(401).end() unless req.user?.hasRole 'administrator'

    Bucket.findById req.params.bucketId, (err, bucket) ->
      return res.status(400).send(e: err) if err
      return res.status(404).end() unless bucket

      User.findById req.params.userId, (err, user) ->
        return res.status(400).send(e: err) if err
        return res.status(404).end() unless user

        user.upsertRole req.body.role, bucket, (err, user) ->
          return res.status(400).send(e: err) if err

          u = user.toJSON()
          u.role = req.body.role
          u.bucketId = req.params.bucketId

          res.status(200).send u

  .delete (req, res) ->
    return res.status(401).end() if !req.user || !req.user.hasRole('administrator')

    Bucket.findById req.params.bucketId, (err, bucket) ->
      return res.status(400).send(e: err) if err
      return res.status(404).end() unless bucket

      User.findById req.params.userId, (err, user) ->
        return res.status(400).send(e: err) if err
        return res.status(404).end() unless user

        user.removeRole bucket, (err, user) ->
          return res.status(400).send(e: err) if err

          res.status(204).end()
