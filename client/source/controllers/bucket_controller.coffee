Controller = require 'lib/controller'
StartView = require 'views/start'

module.exports = class BucketController extends Controller
  
  list: ->
    @view = new StartView

  missing: ->
    console.log 'Page missing!', arguments