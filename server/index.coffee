async = require 'async'

_ = require 'underscore'
colors = require 'colors'
cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'
session = require 'cookie-session'
compression = require 'compression'
responseTime = require 'response-time'
express = require 'express'
hbs = require 'hbs'
expressWinston = require 'express-winston'
events = require 'events'

Build = require './models/build'

logger = require './lib/logger'
config = require './lib/config'
bucketUtil = require './lib/util'

class Buckets extends events.EventEmitter
  listening: no

  constructor: (options={}, callback) ->
    @config = config.load options
    logger.verbose 'Starting Buckets', config: config.toString(), callback: callback?

    @generateBuilds callback || ->

    # Turn on NewRelic
    try
      newrelicConfig = require '../newrelic'
      if newrelicConfig.config.license_key
        newrelic = require 'newrelic'
        logger.verbose 'NewRelic Enabled'
        hbs.registerHelper 'newrelic', ->
          new hbs.handlebars.SafeString newrelic.getBrowserTimingHeader()

    catch e
      logger.error 'There was an error loading NewRelic', e

    # Purge Fastly on prod pushes
    if config.get('fastlyApiKey')?.api_key and config.get('fastlyServiceId')?.service_id and config.get('env') is 'production'
      @fastly = require('fastly') config.get 'fastlyApiKey'
      @fastly.purgeAll config.get('fastlyServiceId'), -> logger.info 'Purged Fastly Cache'

    passport = require './lib/auth'

    @routers =
      admin: require './routes/admin'
      api: require './routes/api'
      frontend: require './routes/frontend'

    @app = express()

    @app.use (req, res, next) ->
      req.startTime = Date.now()
      next()

    # Handle cookies and sessions and stuff
    @app.use compression level: 4
    @app.use responseTime() if config.get('env') isnt 'production'
    @app.use cookieParser config.get('salt')
    @app.use session
      secret: config.get('salt')
      name: 'buckets'

    @app.use bodyParser.json()
    @app.use bodyParser.urlencoded extended: true
    @app.use passport.initialize()
    @app.use passport.session()

    @app.set 'view engine', 'hbs'
    @app.set 'view cache', false
    @app.set 'query parser', 'simple' # reduces risk of MongoDB injection attack

    @app.use expressWinston.logger
      winstonInstance: logger
      expressFormat: yes
      msg: '{{res.statusCode}} {{req.method}} {{res.responseTime}}ms {{req.url}}'.yellow
      level: 'verbose'
      # statusLevels: yes

    if logger.level is 'info'
      @app.use expressWinston.logger
        winstonInstance: logger
        expressFormat: yes
        msg: '{{res.statusCode}} {{req.method}} {{res.responseTime}}ms {{req.url}}'.yellow
        level: 'info'
        meta: no
        # statusLevels: yes

    @app.use "/#{@config.apiSegment}", (req, res, next) ->
      badObject = bucketUtil.checkForDollarKeys req.body, res
      if badObject
        res.status(403).send("Disallowed object in request: " + JSON.stringify(badObject))
      else
        next()

    # Load Routes for the API, admin, and frontend
    @app.use "/#{config.get('apiSegment')}", @routers.api
    @app.use "/#{config.get('adminSegment')}", @routers.admin
    @app.use @routers.frontend

    @app.use expressWinston.errorLogger
      winstonInstance: logger

    @start() if config.get('autoStart')

  start: (done) ->
    done?() if @server
    @server = @app.listen config.get('port'), =>
      @listening = yes
      logger.info ("Buckets is running at " + "http://localhost:#{config.get('port')}/".underline.bold).yellow

  stop: (done) ->
    return done?() unless @listening or not @server
    @server.close =>
      @listening = no
      done()

  generateBuilds: (callback) ->
    path = config.get('buildsPath')
    logger.profile 'Generated builds'

    async.parallel [
      (callback) ->
        Build.scaffold 'staging', callback
    ,
      (callback) ->
        # Get the current live build
        Build.getLive (err, build) =>
          # If it exists, unpack it,
          # Otherwise create from scratch
          if build
            build.unpack callback
          else
            Build.scaffold 'live', callback
    ], =>
      logger.profile 'Generated builds'
      @emit 'buildsGenerated'
      @generated = yes
      callback?()

# There can be only one #highlander
buckets = null
module.exports = (options={}, callback) ->
  if _.isFunction(options) and !callback
    callback = options
    options = {}

  if buckets?
    buckets.config.load options
    if callback
      if buckets.generated
        callback()
      else
        buckets.once 'buildsGenerated', callback
    buckets
  else
    buckets = new Buckets options, callback
