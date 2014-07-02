express = require 'express'

User = require '../../models/user'
Bucket = require '../../models/bucket'
Entry = require '../../models/entry'
Route = require '../../models/route'

bucketSeed = require '../../models/seed/buckets'
routeSeed = require '../../models/seed/routes'
entrySeed = require '../../models/seed/entries'

module.exports = app = express()

app.post '/install', (req, res) ->
  User.count (err, count) ->

    return res.send err if err
    return res.send error: 'This deployment has already been installed.' unless count is 0

    newUser = new User req.body
    newUser.roles = [name: 'administrator']

    renderError = (err) ->
      res.send 400, err

    newUser.save (err, user) ->
      return res.send err, 400 if err
      console.log 'user saved', user

      Route.create(routeSeed).then( ->
        console.log 'bucket created', arguments
        Bucket.create bucketSeed
      ).then( (bucket) ->
        entry.bucket = bucket._id for entry in entrySeed
        Entry.create entrySeed
      , renderError).then ->
        console.log 'route created', arguments
        req.login newUser, ->
          res.send newUser, 201
