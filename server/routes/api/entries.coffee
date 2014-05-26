express = require 'express'

module.exports = app = express()

app.route('/entries')
  .post (req, res) ->
    newUser = new User req.body
    
    if newUser.checkValid()
      newUser.save().then (user) ->
        res.send user

  .get (req, res) ->
    User.filter({}).run().then (users) ->
      res.send users