express = require 'express'

Bucket = require '../../models/bucket'
Entry = require '../../models/entry'

module.exports = app = express()

###
  @api {post} /entries Create an entry
  @apiVersion 0.0.4
  @apiGroup Entries
  @apiName PostEntry

  @apiParam {String} bucket Bucket ID
  @apiParam {String} author Author ID
  @apiParam {String} [status="live"] One of 'draft', 'live', 'pending', or 'rejected'. _See below for differences for contributors._
  @apiParam (Contributors) {String} [status="submitted"] Available options are 'draft' and 'submitted' (using `live` will automatically switch to `submitted`).
  @apiParam {String} [publishDate="Now"] Can accept a DateTime or a relative date (eg. "Tomorrow at 9am").
  @apiParam {Array} [keywords] Array of keywords (or comma-separated String) used for tagging and/or search results.
  @apiParam {String} [description] Description used for search results.
  @apiParam {Object} content An special field for an object with custom field data. The accepted custom fields for an Entry depend on it’s which Bucket is it assigned to.
###

###
  @api {post} /entries Create an entry
  @apiVersion 0.0.5
  @apiGroup Entries
  @apiName PostEntry

  @apiParam {String} bucket Bucket ID
  @apiParam {String} author Author ID
  @apiParam {String} [status="live"] One of 'draft', 'live', 'pending', or 'rejected'. _See below for differences for contributors._
  @apiParam (Contributors) {String} [status="submitted"] Available options are 'draft' and 'submitted' (using `live` will automatically switch to `submitted`).
  @apiParam {String} [publishDate="Now"] Can accept a DateTime or a relative date (eg. "Tomorrow at 9am").
  @apiParam {String} [keywords] String of comma-separated keywords used for tagging and/or search results.
  @apiParam {String} [description] Description used for search results.
  @apiParam {Object} content An special field for an object with custom field data. The accepted custom fields for an Entry depend on it’s which Bucket is it assigned to.
###

###
  @api {get} /entries Get Entries
  @apiDescription This is the primary endpoint for retrieving a list of entries, regardless of Bucket. By default, it will respond with an RSS-style list of entries, ie. Only entries which are live, and dated in the past. It's easy to customize what types of entries are retrieved, though, with a variety of flexible, optional parameters.
  @apiVersion 0.0.4
  @apiGroup Entries
  @apiName GetEntries

  @apiParam {String} [bucket] A single, or pipeline-separated, list of Bucket slugs with which to filter entries, eg. 'articles|videos'
  @apiParam {String} [since] A string representing an bottom limit on the publishDate of an Entry. Can be any standard DateTime format, or a relative date, like "Yesterday".
  @apiParam {String} [until=Now] A string representing an upper limit on the publishDate of an Entry. Can be any standard DateTime format, or a relative date, like "Yesterday".
  @apiParam {Number} [limit=10] The maximum number of Entries to return. Useful for pagination.
  @apiParam {Number} [skip] The number of Entries to skip. Useful for pagination.
  @apiParam {String} [status="live"] The status of items to return. Can pass an empty string for all types. Available options are 'live', 'draft', 'submitted', and 'rejected'.
  @apiParam {String} [sort="-publishDate"] How items are sorted. Uses a [mongoose style sort string](#).
  @apiParam {String} [slug] A slug for a specific Entry to retrieve.
###

app.route '/entries'
  .post (req, res) ->
    Bucket.findById req.body.bucket, (e, bucket) ->
      return res.status(400).send(e) if e
      return res.status(404).end() unless bucket
      return res.status(401).end() unless req.user?.hasRole(['editor', 'contributor'], bucket)

      # todo: Move this to the model
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

###
  @api {get} /entries/keywords Get keywords
  @apiDescription Show distinct keywords used across all entries.
  @apiVersion 0.0.4
  @apiGroup Entries
  @apiName GetKeywords

  @apiSuccess {Array} keywords Array of unique keywords.
###

###
  @api {get} /entries/keywords Get keywords
  @apiGroup Entries
  @apiName GetKeywords
  @apiVersion 0.0.5
  @apiSuccess {Object[]} keywords Array of unique keywords.
  @apiSuccess {String} keywords.keyword Array of unique keywords.
  @apiSuccess {Number} keywords.count Number of times this keyword has been used.
###
app.route('/entries/keywords')
  .get (req, res) ->
    # This is like a mapReduce but much faster
    # It gives the counts for popular keywords
    Entry
      .aggregate()
      .project 'keywords keyword'
      .unwind 'keywords'
      .group
        _id: '$keywords'
        count: $sum: 1
      .sort
        count: -1
      .project
        _id: 0
        keyword: '$_id'
        count: '$count'
      .exec (e, keywords) ->
        return res.status(400).end() if e
        res.status(200).send keywords

###
  @api {get} /entries/:id Get Entry
  @apiVersion 0.0.4
  @apiGroup Entries
  @apiName GetEntry

  @apiParam {String} id Entry's unique ID (sent with the URL).
###

###
  @api {put} /entries/:id Update an Entry
  @apiVersion 0.0.4
  @apiGroup Entries
  @apiName PutEntry

  @apiParam {String} id Entry's unique ID.
###

###
  @api {delete} /entries/:id Remove an Entry
  @apiVersion 0.0.4
  @apiGroup Entries
  @apiName DeleteEntry

  @apiParam {String} id Entry's unique ID.
###

app.route('/entries/:entryID')
  .get (req, res) ->
    Entry.findOne(_id: req.params.entryID).populate('bucket author').exec (err, entry) ->
      if entry
        res.status(200).send entry
      else
        res.status(404).end()

  .put (req, res) ->
    Entry.findById req.params.entryID, (err, entry) ->
      return res.status(400).send err if err

      entry.set(req.body).save (err, entry) ->
        return res.status(400).send err if err

        entry.populate 'bucket author', ->
          res.status(200).send entry

  .delete (req, res) ->
    Entry.findById(req.params.entryID).remove (err) ->
      if err
        res.status(400).send e: err
      else
        res.status(204).end()
