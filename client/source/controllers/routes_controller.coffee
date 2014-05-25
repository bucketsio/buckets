Controller = require 'lib/controller'
RoutesList = require 'views/routes/list'

module.exports = class RoutesController extends Controller

  list: ->
    @view = new RoutesList