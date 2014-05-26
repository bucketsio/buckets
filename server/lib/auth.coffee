passport = require 'passport'
LocalStrategy = require('passport-local').Strategy
User = require '../models/user'

passport.use new LocalStrategy (username, password, done) ->
  User.filter(email: username).nth(0).run (err, user) ->
    return done err if err
    return done null, false, message: "Incorrect username." unless user
    return done null, false, message: "Incorrect password." unless user.checkPassword(password)
    
    done null, user

passport.serializeUser (user, done) -> done null, user.id

passport.deserializeUser (id, done) ->
  User.get(id).run (err, user) -> done err, user

module.exports = passport