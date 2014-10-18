# Middleware to control the rest of the requests.
async = require 'async'
hbs = require 'hbs'
fastly = require 'fastly'
pathRegexp = require 'path-to-regexp'
express = require 'express'
_ = require 'underscore'
path = require 'path'
config = require '../config'
logger = require '../lib/logger'
Route = require '../models/route'
fs = require 'fs'
vhost = require 'vhost'
harp = require 'harp'
pkg = require '../../package'

module.exports = app = express()

require('../lib/renderer')(hbs)

plugins = app.get 'plugins'

if config.host
  # Handle staging/personal build environments
  app.use vhost "*.#{config.host}", (req, res, next) ->
    unless req.user?.hasRole ['administrator']
      # This isn’t authorized, do a redirect
      # console.log 'Unauthorized user on staging', req.user
      port = if config.port isnt '80'
        ":#{config.port}"
      else
        ''
      res.redirect "#{req.protocol}://#{config.host}#{port}#{req.url}"
    else
      buildEnv = req.vhost[0]

      # Check buildEnv dir exists
      fs.exists "./builds/#{buildEnv}", (exists) ->
        # console.log "Using #{buildEnv} statics".rainbow, exists
        if exists
          app.set 'views', "./builds/#{buildEnv}"
          req.originalUrl = req.url
          req.url = "/#{buildEnv}#{req.url}"
          req.previewMode = yes
        next()

# For non-vhost users, use the live build
app.use (req, res, next) ->
  unless req.previewMode
    req.originalUrl = req.url
    req.url = "/live#{req.url}"
    app.set 'views', "./builds/live"
  # console.log 'just passing thru...', req.url
  next()

# One week
app.use express.static(config.buildsPath, maxAge: 86400000 * 7), harp.mount("./builds/"), (req, res, next) ->
  # console.log 'what?!', req.originalUrl, req.url
  req.url = req.originalUrl if req.originalUrl
  delete req.originalUrl
  next()

app.all '/:frontend*?', (req, res, next) ->
  # Cheating a bit, but if it's not in their public files, they shouldn't be serving it w/Templates
  return next() if /\.(gif|jpg|css|js|ico|woff|ttf)$/.test req.path

  # We could use a $where here, but it's basically the same
  # since a basic $where scans all rows (plus this gives us more flexibility)
  Route.find {}, 'urlPattern urlPatternRegex template keys', sort: 'sort', (err, routes) ->
    return next() unless routes?.length or config.catchAll is yes

    # dynamic renderTime helper
    # (startTime is set in index.coffee)
    hbs.registerHelper 'renderTime', ->
      now = new Date
      (now - req.startTime) + 'ms'

    # set the status code from a Template like this:
    # {{statusCode 404}}
    hbs.registerHelper 'statusCode', (val) ->
      res.status val unless res.headersSent
      ''

    # Used to block rendering if {{next}} is called
    globalNext = false
    hasRendered = no
    hbs.registerHelper 'next', -> globalNext = true

    matchingRoutes = []

    templateData =
      adminSegment: config.adminSegment
      user: req.user
      assetPath: if config.fastly?.cdn_url and config.env is 'production' and not req.user?.previewMode
          "http://#{config.fastly.cdn_url}/"
        else
          "/"
      errors: []
      buckets:
        version: pkg.version

    for route in routes
      continue unless route.urlPatternRegex.test req.path
      matches = route.urlPatternRegex.exec req.path

      # Prepare the global template data
      localTemplateData = _.clone templateData

      localTemplateData.route = route
      localTemplateData.req =
        body: req.body
        path: req.path
        query: req.query
        params: {}
      localTemplateData.req.params[key.name] = matches[i+1] for key, i in route.keys
      matchingRoutes.push localTemplateData

    # The magical, time-traveling Template lookup/renderer
    async.detectSeries matchingRoutes, (localTemplateData, callback) ->

      logger.error 'Attempting to render page twice.' if hasRendered

      return if hasRendered is yes

      localTemplateData.errors = templateData.errors
      res.render localTemplateData.route.template, localTemplateData, (err, html) ->
        if globalNext
          globalNext = false
          callback false
          logger.debug '{{next}} was called.'
        else if err
          tplErr = {}
          tplErr[localTemplateData.route.template] = err.message
          templateData.errors.push tplErr
          callback false

        else if html
          if res.headersSent
            logger.debug 'Rendered HTML, but headers sent.'
            callback false
          else
            logger.debug 'Rendering.'.green
            hasRendered = yes
            res.send html
            callback yes
        else if not html
          logger.debug 'No HTML came back.'
          callback false
        else
          logger.error 'WTF. I really don’t know how we get here'
          callback false

    , (rendered) ->
      return if rendered
      # console.log 'Rendering error page'
      return next() unless config.catchAll

      res.render 'error', templateData, (err, html) ->
        logger.error 'Buckets caught an error trying to render the error page.' if err
        if err
          res.status(404)
          if config.env is 'production' or res.headersSent or config.catchAll
            res.end()
          else
            next()
        else
          res.status(404).send html
