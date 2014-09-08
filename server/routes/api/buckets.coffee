express = require 'express'

Bucket = require '../../models/bucket'
User = require '../../models/user'

module.exports = app = express()

###
  @apiDefineStructure Bucket
  @apiParam {String} name Name of the Bucket. Typically in plural form, eg. "Articles"
  @apiParam {String} slug Slug for the bucket, a string without spaces, for use in template tags and API calls, eg. "articles"
  @apiParam {String} [titlePlaceholder="New {{singular}}"] The placeholder text used when a user is adding a new Entry into this Bucket.
  @apiParam {Object[]} [fields] Array of Fields for this Bucket. Fields define the structure of a Bucket’s content.
  @apiParam {String} fields.name Name of the field (used for UI labels).
  @apiParam {String} fields.slug Slug for the field, used in templates as the field’s key.
  @apiParam {String} fields.fieldType The type of Field, which defines how its input form is rendered, how it is validated, and how it saves data to the database. The fieldType value **must** match a FieldType provided by Buckets by default (`text`, `textarea`, `checkbox`, `number`), or an installed Buckets plugin (`location` and `markdown` are currently built-in by default).
  @apiParam {Boolean} [fields.required] Set to true if you want this field to be required.
  @apiParam {String} [fields.instructions] Optional instructions to show in the UI with the field.
  @apiParam {Object} [fields.settings] Optional key-value storage for a Field's settings.
  @apiParam {String} [color="teal"] Color for the Bucket, with options of 'teal', 'purple', 'red', 'yellow', 'blue', 'orange', and 'green'.
  @apiParam {String} [icon="edit"] Icon for the Bucket, one of 'edit', 'photos', 'calendar', 'movie', 'music-note', 'map-pin', 'quote', 'artboard', or 'contacts-1' (subject to change...)
  @apiParam {String} [singular] The name of one "Entry" within this Bucket, eg. "Article." Will automatically be created using an inflection library.
###

###
  @apiDefineSuccessStructure Members
  @apiSuccessExample Success-Response:
  HTTP/1.1 200 OK
  [
    {
      "name": "Deandra Reynolds",
      "email": "sweetdee@buckets.io",
      "roles": [
        {
          "name": "contributor",
          "resourceType": "Bucket",
          "resourceId": "53f8de974bbbbded1dd21e66",
          "id": "53f9057c50c7a4b233330a4e"
        }
      ],
      "date_created": "2014-08-23T21:16:33.919Z",
      "last_active": "2014-08-23T21:16:33.919Z",
      "email_hash": "b7c1344f136d04570abbb1fe3c2d88ff",
      "id": "53f904b113341f75338bfe1a",
      "role": "contributor",
      "bucketId": "53f8de974bbbbded1dd21e66"
    }
  ]
###

###
  @apiDefineSuccessStructure Bucket
  @apiSuccessExample Success-Response:
  HTTP/1.1 200 OK
  {
    color: "red"
    fields: []
    icon: "calendar"
    id: "53f7a4ccfae2c95b086e6815"
    name: "Meetups"
    singular: "Meetup"
    slug: "meetups"
    titleLabel: "Title"
  }
###

###
  @apiDefineSuccessStructure BucketsList
  @apiSuccess {Object[]} results List of buckets. *Currently, this endpoint simply returns an the results array directly — we will switch to always using an Object with "results" keys soon.*
  @apiSuccessExample Success-Response:
  HTTP/1.1 200 OK
  [
    {
      "singular": "Article",
      "name": "Articles",
      "slug": "articles",
      "fields": [
        {
          "name": "Body",
          "slug": "body",
          "fieldType": "markdown",
          "settings": {
            "size": "lg"
          },
          "dateCreated": "2014-08-23T18:33:40.813Z",
          "id": "53f8de974bbbbded1dd21e67"
        }
      ],
      "color": "teal",
      "icon": "edit",
      "titleLabel": "Title",
      "id": "53f8de974bbbbded1dd21e66"
    },
    {
      "singular": "Meetup",
      "name": "Meetups",
      "slug": "meetups",
      "fields": [
        {
          "name": "Body",
          "slug": "body",
          "fieldType": "markdown",
          "settings": {
            "size": "lg"
          },
          "dateCreated": "2014-08-23T18:33:40.813Z",
          "id": "53f8de974bbbbded1dd21e6a"
        },
        {
          "name": "Location",
          "slug": "location",
          "fieldType": "location",
          "settings": {
            "placeholder": "Address"
          },
          "dateCreated": "2014-08-23T18:33:40.813Z",
          "id": "53f8de974bbbbded1dd21e69"
        }
      ],
      "color": "red",
      "icon": "calendar",
      "titleLabel": "Title",
      "id": "53f8de974bbbbded1dd21e68"
    }
  ]

###

###
  @api {post} /buckets Create a Bucket
  @apiVersion 0.0.4
  @apiGroup Buckets
  @apiName PostBucket
  @apiStructure Bucket

  @apiPermission administrator
  @apiSuccessStructure Bucket
###

###
  @api {get} /buckets Get Buckets
  @apiDescription List Buckets you have access to.
  @apiVersion 0.0.4
  @apiGroup Buckets
  @apiName GetBuckets

  @apiPermission contributor/editor/administrator

  @apiSuccessStructure BucketsList
###

app.route('/buckets')
  .post (req, res) ->
    return res.status(401).end() unless req.user?.hasRole ['administrator']

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


###
  @api {delete} /buckets/:id Remove a Bucket
  @apiVersion 0.0.4
  @apiDescription Removes a Bucket and all of its Entries.
  @apiGroup Buckets
  @apiName DeleteBucket

  @apiPermission administrator

  @apiSuccessExample Success-Response:
  HTTP/1.1 204
###

###
  @api {put} /buckets/:id Update a Bucket
  @apiVersion 0.0.4
  @apiGroup Buckets
  @apiName PutBucket

  @apiStructure Bucket
  @apiSuccessStructure Bucket

  @apiPermission administrator
###

app.route('/buckets/:bucketID')
  .delete (req, res) ->
    return res.status(401).end() unless req.user?.hasRole ['administrator']

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
    return res.status(401).end() unless req.user?.hasRole ['administrator']

    delete req.body._id
    Bucket.findOne {_id: req.params.bucketID}, (err, bucket) ->
      return res.status(400).send e: err if err
      bucket.set(req.body).save (err, bucket) ->
        return res.status(400).send err if err
        res.status(200).send bucket

###
  @api {get} /buckets/:id/members Get Members
  @apiDescription Get current members of a Bucket (ie. editors and contributors)
  @apiVersion 0.0.4
  @apiGroup Buckets
  @apiName GetMembers

  @apiPermission administrator

  @apiSuccessStructure Members
###

app.route('/buckets/:bucketId/members')
  .get (req, res) ->
    return res.status(401).end() unless req.user?.hasRole 'administrator'

    Bucket.findById req.params.bucketId, (err, bucket) ->
      return res.status(400).send(e: err) if err
      return res.status(404).end() unless bucket

      bucket.getMembers (err, users) ->
        return res.status(400).send(e: err) if err

        res.status(200).send users.map (user) ->
          u = user.toJSON()
          u.role = user.getRolesForResource(bucket)[0].name
          u.bucketId = req.params.bucketId
          u

###
  @api {put} /buckets/:id/members/:userID Add a Member
  @apiDescription Add a member (contributor or editor) to a Bucket.
  @apiVersion 0.0.4
  @apiGroup Buckets
  @apiName PostMember

  @apiParam {String} id ID of the Bucket.
  @apiParam {String} userID ID of the User/member.
  @apiParam {String} role Either 'contributor' or 'editor'.

  @apiPermission administrator

  @apiSuccessStructure Members
###

###
  @api {delete} /buckets/:id/members/:userID Remove a Member
  @apiDescription Remove a member's access to a Bucket.
  @apiVersion 0.0.4
  @apiGroup Buckets
  @apiName DeleteMember

  @apiParam {String} id ID of the Bucket.
  @apiParam {String} userID ID of the User/member.

  @apiPermission administrator

  @apiSuccessStructure Members
###

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
    return res.status(401).end() unless req.user?.hasRole 'administrator'

    Bucket.findById req.params.bucketId, (err, bucket) ->
      return res.status(400).send(e: err) if err
      return res.status(404).end() unless bucket

      User.findById req.params.userId, (err, user) ->
        return res.status(400).send(e: err) if err
        return res.status(404).end() unless user

        user.removeRole bucket, (err, user) ->
          return res.status(400).send(e: err) if err

          res.status(204).end()
