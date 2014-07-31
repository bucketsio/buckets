Chaplin = require 'chaplin'

module.exports = class Collection extends Chaplin.Collection
  initialize: ->
    @ajaxPool = []
    super

  fetch: ->
    jqPromise = super
    @ajaxPool.push jqPromise

    jqPromise.fail (jqXHR, statusCode) ->
      console.warn 'Collection Ajax error:', arguments
      if "#{jqXHR?.status}".charAt(0) is '5' or statusCode is 'parsererror' or statusCode is 'timeout'
        Chaplin.utils.redirectTo 'error#general'

    jqPromise.always =>
      idx = @ajaxPool.indexOf jqPromise
      @ajaxPool.splice idx, 1 unless idx is -1

  dispose: ->
    xhr.abort() for xhr in @ajaxPool
    super
