# Middleware to control the rest of the requests.
hbs = require 'hbs'
pathRegexp = require 'path-to-regexp'
express = require 'express'
_ = require 'underscore'

config = require '../config'
Route = require '../models/route'

module.exports = app = express()
tplPath = config.buckets?.templatePath

hbs.registerHelper 'inspect', (thing, options) ->
  thing = thing or @

  entities =
    '<': '&lt;'
    '>': '&gt;'
    '&': '&amp;'

  json = JSON
    .stringify thing, null, 2
    .replace /[&<>]/g, (key) -> entities[key]

  new hbs.handlebars.SafeString "<pre>#{json}</pre>"

require('../lib/renderer')(hbs)

app.set 'views', tplPath
app.set 'view cache', off

app.use express.static config.buckets.publicPath, maxAge: 86400000 * 7 # One week

plugins = app.get 'plugins'

app.get '*', (req, res, next) ->

  # dynamic renderTime helper
  startTime = new Date

  getTime = ->
    now = new Date
    (now.getTime() - startTime.getTime()) + 'ms'

  hbs.registerHelper 'renderTime', -> getTime()

  templateData =
    adminSegment: config.buckets.adminSegment
    # Expose select items from the request object
    req:
      body: req.body
      path: req.path
      query: req.query unless _.isEmpty(req.query)
      params: {} # We fill this manually later
    user: req.user

  renderError = ->
    next() unless config.buckets.catchAll

    templateData.errorCode = 404
    templateData.errorText = 'Page missing'

    res.render 'index', templateData, (err, html) ->
      console.log 'Buckets caught an error trying to render the index', err if err
      if err
        res.send 404, err
      else
        res.send 404, html

  # We could use a $where here, but it's basically the same
  # since a basic $where scans all rows (plus this gives us more flexibility)
  Route.find().exec (err, routes) ->
    throw err if err

    for route in routes
      matches = route.urlPatternRegex?.exec(req.path)

      if matches
        # Add the URL wildcards

        templateData.template = route.template
        templateData.req.params[key.name] = matches[i+1] for key, i in route.keys

        return res.render route.template, templateData, (err, html) ->
          if err
            renderError()
          else
            return res.send html if html

    renderError()
