# Middleware to control the rest of the requests.

async = require 'async'
hbs = require 'hbs'
pathRegexp = require 'path-to-regexp'
express = require 'express'
_ = require 'underscore'

config = require '../config'
Route = require '../models/route'

module.exports = app = express()
tplPath = config.buckets?.templatePath

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
    errors: []

  globalNext = null

  hbs.registerHelper 'next', ->
    if globalNext?
      globalNext false
      throw new Error '{{next}} called'

  # We could use a $where here, but it's basically the same
  # since a basic $where scans all rows (plus this gives us more flexibility)
  Route.find({}, null, sort: 'sort').exec (err, routes) ->
    throw err if err

    matchingRoutes = []

    for route in routes
      matches = route.urlPatternRegex.exec req.path

      if matches
        localTemplateData = _.clone templateData
        localTemplateData.template = route.template
        localTemplateData.req.params[key.name] = matches[i+1] for key, i in route.keys

        matchingRoutes.push localTemplateData

    async.detectSeries matchingRoutes, (localTemplateData, callback) ->
      globalNext = callback
      localTemplateData = _.extend localTemplateData, templateData

      res.render localTemplateData.template, localTemplateData, (err, html) ->
        if err
          tplErr = {}
          tplErr[localTemplateData.template] = err.message
          templateData.errors.push tplErr
          callback false, "#{err.name} #{err.message}"
        else if html
          res.send 200, html
          callback true
        else
          callback false, 'The rendered page was blank.'
    , (rendered) ->
      return if rendered

      templateData.errorCode = 404
      templateData.errorText = 'Page missing'

      res.render 'error', templateData, (err, html) ->
        console.log 'Buckets caught an error trying to render the error page.', err if err

        if err
          res.send 404, err
        else
          res.send 404, html
