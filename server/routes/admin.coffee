express = require 'express'
compress = require 'compression'
hbs = require 'hbs'

config = require '../config'
passport = require '../lib/auth'
User = require '../models/user'

module.exports = app = express()

hbs.registerHelper 'json', (context) ->
  new hbs.handlebars.SafeString JSON.stringify(context)

app.set 'views', "#{__dirname}/../views"
app.use compress()
app.use express.static '#{__dirname}/../public/'

# Special case for install
app.post '/login', passport.authenticate 'local', 
  failureRedirect: "/#{config.buckets.adminSegment}/login"
  successRedirect: "/#{config.buckets.adminSegment}/"

app.get '/logout', (req, res) ->
  req.logout()
  res.redirect "/#{config.buckets.adminSegment}/"

app.all '*', (req, res) ->
  # This is kinda dumb, but whatever
  User.count({}).exec (err, userCount) ->
    res.send 500 if err

    res.render 'admin',
      user: req.user
      adminSegment: config.buckets.adminSegment
      needsInstall: userCount is 0