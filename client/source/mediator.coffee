Chaplin = require 'chaplin'

module.exports = mediator = Chaplin.mediator

mediator.loadPlugin = (name) ->
  promise = new $.Deferred
  Modernizr.load
    load: "/#{@options.adminSegment}/plugins/#{name}.js"
    complete: ->
      promise.resolve()

  promise
