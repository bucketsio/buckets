passport = require 'passport'
LocalStrategy = require('passport-local').Strategy
User = require '../models/user'

passport.use new LocalStrategy (username, password, done) ->
  User.findOne {email: username}, 'passwordDigest', (err, user) ->
    return done err if err
    return done null, false, path: 'username', message: "Incorrect username." unless user
    return done null, false, path: 'password', message: "Incorrect password." unless user.authenticate(password)

    done null, user

passport.serializeUser (user, done) -> done null, user.id

passport.deserializeUser (id, done) ->
  User.findOne {_id: id}, (err, user) ->
    done err, user

module.exports = passport
