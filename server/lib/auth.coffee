passport = require 'passport'
LocalStrategy = require('passport-local').Strategy
User = require '../models/user'

passport.use new LocalStrategy (username, password, done) ->
  User.filter(email: username).nth(0).run (err, user) ->
    done err if err
    done null, false, message: "Incorrect username." unless user
    done null, false, message: "Incorrect password." unless user.checkPassword(password)
    done null, user

passport.serializeUser (user, done) -> done null, user.id

passport.deserializeUser (id, done) ->
  User.get(id).run (err, user) -> done err, user

module.exports = passport