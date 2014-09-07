passport = require 'passport'
LocalStrategy = require('passport-local').Strategy
User = require '../models/user'

passport.use new LocalStrategy (username, password, done) ->
  User.find email: username, 'passwordDigest', limit: 1, (err, user) ->
    return done err if err
    return done null, false, path: 'username', message: "Incorrect username." unless user?.length
    return done null, false, path: 'password', message: "Incorrect password." unless user[0].authenticate?(password)

    done null, user[0]

passport.serializeUser (user, done) -> done null, user.id
passport.deserializeUser (id, done) -> User.find _id: id, null, limit: 1, (e, users) ->
  if users?[0]
    done e, users[0]
  else
    done null, false

module.exports = passport
