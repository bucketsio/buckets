Controller = require 'lib/controller'
RoutesList = require 'views/routes/list'
Routes = require 'models/routes'
Templates = require 'models/templates'

module.exports = class RoutesController extends Controller

  list: ->
    @routes = new Routes
    @templates = new Templates

    $.when(
      @routes.fetch()
      @templates.fetch()
    ).done =>
      @view = new RoutesList
        collection: @routes
        templates: @templates
