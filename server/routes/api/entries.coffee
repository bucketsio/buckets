express = require 'express'

Bucket = require '../../models/bucket'
Entry = require '../../models/entry'

module.exports = app = express()

app.route('/entries')
  .post (req, res) ->
    req.body.keywords = req.body.keywords?.split(',')

    Bucket.findById req.body.bucket, (e, bucket) ->
      return res.status(400).send(e) if e
      return res.status(404).end() unless bucket
      return res.status(401).end() unless req.user?.hasRole(['editor', 'contributor'], bucket)

      if !req.user?.hasRole('editor', bucket) and req.body.status is 'live'
        req.body.status = 'pending'

      newEntry = new Entry req.body

      newEntry.save (err, entry) ->
        if err
          res.status(400).send err
        else
          entry.populate 'bucket author', ->
            res.status(200).send entry

  .get (req, res) ->
    Entry.findByParams req.query, (err, entries) ->
      res.status(200).send entries

app.route('/entries/:entryID')
  .get (req, res) ->
    Entry.findOne(_id: req.params.entryID).populate('bucket author').exec (err, entry) ->
      if entry
        res.status(200).send entry
      else
        res.status(404).end()

  .put (req, res) ->
    Entry.findOne(_id: req.params.entryID).exec (err, entry) ->
      if err
        res.status(400).send err
      else
        entry.set(req.body).save (err, entry) ->
          if err
            res.status(400).send err
          else
            entry.populate 'bucket author', ->
              res.status(200).send entry

  .delete (req, res) ->
    Entry.findOne _id: req.params.entryID, (err, entry) ->
      entry.remove (err) ->
        if err
          res.status(400).send e: err
        else
          res.status(204).end()

app.route('/entries/keywords')
  .get (req, res) ->
    Entry.distinct 'keywords', {}, (err, tags) ->
      res.send tags
