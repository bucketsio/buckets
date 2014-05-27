Backbone = require 'backbone'
Backbone.$ = $
Chaplin = require 'chaplin'

User = require 'models/user'
Layout = require 'views/layout'
routes = require 'routes'

module.exports = class App extends Chaplin.Application
  title: 'Buckets'
  initialize: (@options = {}) ->
    @initRouter routes, {root: '/admin/'}
    @initDispatcher
      controllerPath: 'client/source/controllers/'
      controllerSuffix: '_controller.coffee'

    @mediator = Chaplin.mediator
    @mediator.options = @options
    @mediator.user = new User @options.user if @options.user

    Chaplin.mediator.layout = new Layout
      title: 'Buckets'
      scrollTo: false
      titleTemplate: (data) ->
        str = ''
        str += "#{data.subtitle} · " if data.subtitle
        str += data.title

    # Startup
    @initComposer()
    @start()
    Object.freeze? @

window.App = App
