Backbone = require 'backbone'

Backbone.$ = $

Chaplin = require 'chaplin'

Layout = require 'views/layout'
routes = require 'routes'

module.exports = class App extends Chaplin.Application
  title: 'Buckets'
  initialize: ->
    @initRouter routes, {root: '/admin/', trailing: yes}
    @initDispatcher
      controllerPath: 'client/source/controllers/'
      controllerSuffix: '_controller.coffee'

    @mediator = Chaplin.mediator

    Chaplin.mediator.layout = new Layout
      title: 'Buckets WOOT'

    # startup
    @initComposer()
    @start()
    Object.freeze? @


window.bkts = new App

console.log window.bkts