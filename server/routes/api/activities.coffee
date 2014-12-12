express = require 'express'

Activity = require '../../models/activity'

module.exports = app = express()


app.route('/activities')
  .get (req, res) ->
    return res.status(401).end() unless req.user

    Activity.find({}).sort('-publishDate').limit(20).populate('actor').exec (err, activities) ->
      if err
        res.send err, 400
      else if activities
        res.send activities