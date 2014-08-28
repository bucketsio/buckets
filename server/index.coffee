_ = require 'underscore'
express = require 'express'
cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'
session = require 'cookie-session'
compression = require 'compression'
colors = require 'colors'

passport = require './lib/auth'
baseConfig = require './config'

class Buckets
  routers:
    admin: require './routes/admin'
    api: require './routes/api'
    frontend: require './routes/frontend'

  constructor: ->
    @app = express()

  init: (config={}) ->
    @config = _.extend baseConfig, config

    # Handle cookies and sessions and stuff
    @app.use compression()
    @app.use cookieParser @config.buckets.salt
    @app.use session
      secret: @config.buckets.salt
      name: 'buckets'
    @app.use bodyParser.json()
    @app.use bodyParser.urlencoded extended: true
    @app.use passport.initialize()
    @app.use passport.session()

    # Load Routes for the API, admin, and frontend
    @app.use "/#{@config.buckets.apiSegment}", @routers.api
    @app.use "/#{@config.buckets.adminSegment}", @routers.admin
    @app.use @routers.frontend

    @app.set 'view engine', 'hbs'

    @start() if @config.buckets.autoStart

    @

  start: (done) ->
    done?() if @server

    @server ?= @app.listen @config.buckets.port, =>
      console.log ("\nBuckets is running at " + "http://localhost:#{@config.buckets.port}/".underline.bold).yellow
      done?()

module.exports = new Buckets
