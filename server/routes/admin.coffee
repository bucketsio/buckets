express = require 'express'
compress = require 'compression'
hbs = require 'hbs'

config = require '../config'
plugins = require '../lib/plugins'
passport = require '../lib/auth'
User = require '../models/user'

module.exports = app = express()

hbs.registerHelper 'json', (context) ->
  new hbs.handlebars.SafeString JSON.stringify(context)

app.set 'views', "#{__dirname}/../views"
app.use compress()
app.use express.static '#{__dirname}/../public/', maxAge: 86400000 * 7 # One week

# Special case for install
app.post '/login', passport.authenticate('local', failureRedirect: "/#{config.buckets.adminSegment}/login"), (req, res, next) ->
  res.redirect if req.user and req.body.next
    req.body.next
  else
    "/#{config.buckets.adminSegment}/"

app.get '/logout', (req, res) ->
  req.logout()
  res.redirect "/#{config.buckets.adminSegment}/"

app.all '*', (req, res) ->
  # This is kinda dumb, but whatever
  User.count({}).exec (err, userCount) ->
    res.send 500 if err

    localPlugins = plugins.load()

    res.render 'admin',
      user: req.user
      env: config.buckets.env
      plugins: localPlugins
      adminSegment: config.buckets.adminSegment
      apiSegment: config.buckets.apiSegment
      needsInstall: userCount is 0
