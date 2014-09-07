# Middleware to control the rest of the requests.

async = require 'async'
hbs = require 'hbs'
pathRegexp = require 'path-to-regexp'
express = require 'express'
_ = require 'underscore'

config = require '../config'
Route = require '../models/route'

module.exports = app = express()
tplPath = config.templatePath

require('../lib/renderer')(hbs)

app.set 'views', tplPath
app.set 'view cache', off

app.use express.static config.publicPath, maxAge: 86400000 * 7 # One week

plugins = app.get 'plugins'

app.all '/:frontend*?', (req, res, next) ->

  # Cheating a bit, but if it's not in their publicPath, they shouldn't be serving it w/Templates
  return next() if req.path.match /\.(gif|jpg|css|js|ico)$/

  # We could use a $where here, but it's basically the same
  # since a basic $where scans all rows (plus this gives us more flexibility)
  Route.find {}, null, sort: 'sort', (err, routes) ->
    return next() unless routes?.length or config.catchAll is yes

    # dynamic renderTime helper
    hbs.registerHelper 'renderTime', ->
      now = new Date
      (now - req.startTime) + 'ms'

    # Ability to set the status code from the frontend
    hbs.registerHelper 'statusCode', (val) ->
      res.status val unless res.headersSent
      ''

    # Prepare the global template data
    templateData =
      adminSegment: config.adminSegment
      user: req.user
      errors: []

    globalNext = false # We’ll assign our render callback to this
    hbs.registerHelper 'next', ->
      globalNext = true

    matchingRoutes = []

    for route in routes

      matches = route.urlPatternRegex.exec req.path

      if matches
        localTemplateData = _.clone templateData
        localTemplateData.route = route
        localTemplateData.req =
          body: req.body
          path: req.path
          query: req.query unless _.isEmpty(req.query)
          params: {}
        localTemplateData.req.params[key.name] = matches[i+1] for key, i in route.keys
        matchingRoutes.push localTemplateData

    # The magical, time-traveling Template lookup/renderer
    async.detectSeries matchingRoutes, (localTemplateData, callback) ->
      localTemplateData = _.extend localTemplateData, templateData # Re-grab the global stuff (for errors)
      res.render localTemplateData.route.template, localTemplateData, (err, html) ->

        if globalNext
          globalNext = false
          callback false
          # console.log '{{next}} was called.'
        else if err
          # console.log 'Hit error, going to next match.', err
          tplErr = {}
          tplErr[localTemplateData.route.template] = err.message
          templateData.errors.push tplErr
          callback false

        else if html
          if res.headersSent
            # console.log 'Rendered HTML, but headers sent.'
            callback false
          else
            # console.log 'Rendering.'
            res.send html
            callback yes
        else if not html
          # console.log 'No HTML came back.'
          callback false
        else
          # console.log 'WTF. I really don’t know how we get here'
          callback false

    , (rendered) ->
      return if rendered
      return next() unless config.catchAll

      res.render 'error', templateData, (err, html) ->
        console.log 'Buckets caught an error trying to render the error page.', err if err
        if err
          res.status(500)

          if config.env is 'production' or res.headersSent
            res.end()
          else
            res.send """
              <p><strong>Buckets caught an error trying to render the error page (rough).</strong></p>

              #{err}
            """
        else
          res.status(404).send html
