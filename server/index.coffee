dotenv = require 'dotenv'
dotenv.load()

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

class Buckets extends events.EventEmitter
  listening: no

  constructor: (config={}, callback) ->
    @config = require './config'
    @config = _.extend @config, config

    logger.verbose 'Starting Buckets', config: @config, callback: callback?
    callback ?= ->
    @generateBuilds callback

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
    if @config.fastly?.api_key and @config.fastly?.service_id and @config.env is 'production'
      fastly = require('fastly')(@config.fastly.api_key)
      fastly.purgeAll @config.fastly.service_id, -> logger.error 'Purged Fastly Cache'.red

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
    @app.use responseTime() if @config.env isnt 'production'
    @app.use cookieParser @config.salt
    @app.use session
      secret: @config.salt
      name: 'buckets'
      # domain: ".#{@config.host}" if @config.host

    @app.use bodyParser.json()
    @app.use bodyParser.urlencoded extended: true
    @app.use passport.initialize()
    @app.use passport.session()

    @app.set 'view engine', 'hbs'
    @app.set 'view cache', no

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

    # Load Routes for the API, admin, and frontend
    @app.use "/#{@config.apiSegment}", @routers.api
    @app.use "/#{@config.adminSegment}", @routers.admin
    @app.use @routers.frontend

    @app.use expressWinston.errorLogger
      winstonInstance: logger

    @start() if @config.autoStart

  start: (done) ->
    done?() if @server
    @server = @app.listen @config.port, =>
      @listening = yes
      logger.info ("Buckets is running at " + "http://localhost:#{@config.port}/".underline.bold).yellow

  stop: (done) ->
    return done?() unless @listening or not @server
    @server.close =>
      @listening = no
      done()

  generateBuilds: (callback) ->
    path = @config.buildsPath
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
module.exports = (config={}, callback) ->
  if _.isFunction(config) and !callback
    callback = config
    config = {}

  if buckets?
    buckets.config = config
    if callback
      if buckets.generated
        callback()
      else
        buckets.once 'buildsGenerated', callback

    buckets
  else
    buckets = new Buckets config, callback
