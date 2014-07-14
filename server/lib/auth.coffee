passport = require 'passport'
LocalStrategy = require('passport-local').Strategy
User = require '../models/user'

passport.use new LocalStrategy (username, password, done) ->
  User.findOne {email: username}, (err, user) ->
    return done err if err
    return done null, false, message: "Incorrect username." unless user
    return done null, false, message: "Incorrect password." unless user.authenticate(password)

    done null, user

passport.serializeUser (user, done) -> done null, user.id

passport.deserializeUser (id, done) ->
  User.findOne {_id: id}, '-passwordDigest -resetPasswordToken -passwordDigest', (err, user) ->
    done err, user

module.exports = passport
