express = require 'express'

Bucket = require '../../models/bucket'
Entry = require '../../models/entry'

module.exports = app = express()

app.route('/entries')
  .post (req, res) ->
    req.body.keywords = req.body.keywords?.split(',')

    Bucket.findById req.body.bucket, (e, bucket) ->
      return res.send(400, e) if e
      return res.send(404) unless bucket
      return res.send(401) unless req.user?.hasRole(['editor', 'contributor'], bucket)

      if !req.user?.hasRole('editor', bucket) and req.body.status is 'live'
        req.body.status = 'pending'

      newEntry = new Entry req.body

      newEntry.save (err, entry) ->
        if err
          res.send 400, err
        else
          entry.populate 'bucket author', ->
            res.send 200, entry

  .get (req, res) ->
    Entry.findByParams req.query, (err, entries) ->
      res.send 200, entries

app.route('/entries/:entryID')
  .get (req, res) ->
    Entry.findOne(_id: req.params.entryID).populate('bucket author').exec (err, entry) ->
      if entry
        res.send entry
      else
        res.send 404

  .put (req, res) ->
    Entry.findOne(_id: req.params.entryID).exec (err, entry) ->
      if err
        res.send 400, err
      else
        entry.set(req.body).save (err, entry) ->
          if err
            res.send 400, err
          else
            entry.populate 'bucket author', ->
              res.send 200, entry

  .delete (req, res) ->
    delete req.body._id
    Entry.remove _id: req.params.entryID, (err) ->
      if err
        res.send e: err, 400
      else
        res.send {}, 200

app.route('/entries/keywords')
  .get (req, res) ->
    Entry.distinct 'keywords', {}, (err, tags) ->
      res.send tags
