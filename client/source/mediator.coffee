Chaplin = require 'chaplin'

module.exports = mediator = Chaplin.mediator

mediator.loadPlugin = (name, force=no) ->

  return if @plugins[name] is false

  promise = new $.Deferred

  return promise.resolve() if @plugins?[name] and !force

  Modernizr.load
    load: "/#{@options.adminSegment}/plugins/#{name}.js"
    complete: ->
      promise.resolve()
    fail: =>
      @plugins[name] = false
      promise.reject()

  promise
