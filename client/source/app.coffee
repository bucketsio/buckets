Backbone = require 'backbone'

Backbone.$ = $

Chaplin = require 'chaplin'

Layout = require 'views/layout'
routes = require 'routes'
mediator = require 'mediator'

module.exports = class App extends Chaplin.Application
  title: 'Buckets'
  initialize: ->
    @initRouter routes, root: '/admin/'
    @initDispatcher
      controllerPath: 'client/source/controllers/'
      controllerSuffix: '_controller.coffee'

    @mediator = mediator

    mediator.layout = new Layout
      title: 'Buckets WOOT'

    # startup
    @initComposer()
    @start()
    Object.freeze? @


window.bkts = new App

console.log window.bkts