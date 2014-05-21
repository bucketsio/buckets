express = require 'express'

User = require '../models/user'

module.exports = app = express()

app.post '/users', (req, res) ->
  newUser = new User req.body

  newUser.save().then (user) ->
    res.send newUser

app.get '/users', (req, res) ->
  User.delete().run()
  User.filter({}).run().then (users) ->
    res.send users