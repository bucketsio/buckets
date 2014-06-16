PageView = require 'views/base/page'
EditRouteView = require 'views/routes/edit'

Route = require 'models/route'

tpl = require 'templates/routes/list'

module.exports = class RoutesList extends PageView
  template: tpl

  optionNames: PageView::optionNames.concat ['templates']

  listen:
    'destroy collection': 'render'
    'add collection': 'render'

  events:
    'click [href="#new"]': 'clickNew'
    'click [href="#delete"]': 'clickDelete'
    'click [href="#edit"]': 'clickEdit'

  clickNew: (e) ->
    e.preventDefault()
    newRoute = new Route

    @listenToOnce newRoute, 'sync', =>
      @collection.add(newRoute)

      @subview('editRoute').dispose()
      @render()

    @subview 'editRoute', new EditRouteView
      model: newRoute
      container: @$('.editRoute')
      templates: @templates

  clickDelete: (e) ->
    e.preventDefault()
    if confirm 'Are you sure?'
      model = @collection.findWhere _id: @$(e.currentTarget).closest('.route').data('route-id')
      model.destroy(wait: yes).done ->
        toastr.success 'Route deleted'

  clickEdit: (e) ->
    e.preventDefault()
    route = @collection.findWhere _id: @$(e.currentTarget).closest('.route').data('route-id')

    @listenToOnce route, 'sync', =>
      @subview('editRoute').dispose()
      @render()

    @subview 'editRoute', new EditRouteView
      model: route
      container: @$('.editRoute')
      templates: @templates
