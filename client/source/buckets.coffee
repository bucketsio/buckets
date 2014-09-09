Backbone = require 'backbone'
Cocktail = require 'cocktail'

Backbone.$ = $

Chaplin = require 'chaplin'

User = require 'models/user'
Layout = require 'views/layout'
Handlebars = require 'hbsfy/runtime'
routes = require 'routes'
mediator = require 'mediator'

_ = require 'underscore'

module.exports = class BucketsApp extends Chaplin.Application
  title: 'Buckets'
  initialize: (@options = {}) ->
    @initRouter routes, root: "/#{@options.adminSegment}/"

    @initDispatcher
      controllerPath: 'client/source/controllers/'
      controllerSuffix: '_controller.coffee'

    mediator.options = @options
    mediator.user = new User @options.user if @options.user
    mediator.plugins = {}

    if options.cloudinary
      $.cloudinary.config
        api_key: options.cloudinary.api_key
        cloud_name: options.cloudinary.cloud_name

    mediator.layout = new Layout
      title: 'Buckets'
      titleTemplate: (data) ->
        str = ''
        str += "#{data.subtitle} · " if data.subtitle
        str += data.title

    # Startup
    @initComposer()
    @start()
    Object.freeze? @

  plugin: (key, plugin) ->
    plugin.handlebars = Handlebars
    mediator.plugins[key] = plugin

  @View = require 'lib/view'
  @_ = _
  @mediator = mediator
