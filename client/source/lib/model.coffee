Chaplin = require 'chaplin'
_ = require 'underscore'

module.exports = class Model extends Chaplin.Model
  initialize: ->
    @ajaxPool = []
    super

  api: (url, data, options={}) -> $.ajax _.extend options,
    url: url
    data: data

  sync: ->
    jqPromise = super
    @ajaxPool.push jqPromise

    jqPromise.error (jqXHT, statusCode) ->
      console.warn 'Model AJAX error:', arguments
      if "#{jqXHR?.status}".charAt(0) is '5' or statusCode is 'parsererror' or statusCode is 'timeout'
        Chaplin.utils.redirectTo 'error#general'

    jqPromise.always =>
      idx = @ajaxPool.indexOf jqPromise
      @ajaxPool.splice idx, 1 unless idx is -1

  dispose: ->
    # Abort any pending requests on this Model/collection
    xhr.abort() for xhr in @ajaxPool
    super
