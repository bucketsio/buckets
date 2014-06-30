Chaplin = require 'chaplin'

module.exports = mediator = Chaplin.mediator

mediator.loadPlugin = (name, force=no) ->
  promise = new $.Deferred

  return promise.resolve() if @plugins?[name] and !force

  Modernizr.load
    load: "/#{@options.adminSegment}/plugins/#{name}.js"
    complete: ->
      promise.resolve()

  promise
