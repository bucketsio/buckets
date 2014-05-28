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
    User.find {}, (err, users) ->
      res.send users

app.route('/users/:userID')

  .get (req, res) ->
    User.findOne _id: req.params.userID, (err, user) ->
    res.send user if user

  .delete (req, res) ->
    User.remove _id: req.params.userID, (err) ->
      if err
        res.send e: err, 400
      else
        res.send 200
  .put (req, res) ->
    delete req.body._id
    User.findOneAndUpdate {_id: req.params.userID}, req.body, (err, user) ->
      if err
        res.send e: err, 400
      else
        res.send user, 200