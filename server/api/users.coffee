express = require 'express'

User = require '../models/user'

module.exports = app = express()

app.route('/users')
  .post (req, res) ->
    newUser = new User req.body
    
    if newUser.checkValid()
      newUser.save().then (user) ->
        res.send user

  .get (req, res) ->
    User.filter({}).run().then (users) ->
      res.send users