express = require 'express'

User = require '../../models/user'

module.exports = app = express()

app.route('/users')
  .post (req, res) ->
    newUser = new User req.body
    
    newUser.save (err) ->
      if err
        res.send err, 400
      else
        res.send newUser, 200

  .get (req, res) ->
    User.find (users) ->
      res.send users