express = require 'express'

Activity = require '../../models/activity'

module.exports = app = express()


app.route('/activities')
  .get (req, res) ->
    return res.status(401).end() unless req.user

    Activity
      .find {}
      .sort '-publishDate'
      .limit 20
      .populate 'actor resource.user', 'name email'
      .populate 'resource.entry', 'id'
      .populate 'resource.bucket', 'slug'
      .exec (err, activities) ->
        if err
          res.send err, 400
        else if activities
          res.send activities