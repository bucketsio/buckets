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

  attach: ->
    super
    $sortable = document.getElementById 'sortable-routes'
    new Sortable $sortable,
      onUpdate: (e) =>
        $('#sortable-routes').children().each (i, li) =>
          model = @collection.findWhere id: $(li).children('.route').data 'route-id'

          if model
            model.save sort: i

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
    model = @collection.findWhere id: @$(e.currentTarget).closest('.route').data('route-id')
    if model and confirm "Are you sure you want to delete “#{model.get('urlPattern')}”?"

      model.destroy(wait: yes).done ->
        toastr.success 'Route deleted'

  clickEdit: (e) ->
    e.preventDefault()

    $route = @$(e.currentTarget).closest('.route')
    route = @collection.findWhere id: $route.data('route-id')

    if route
      @listenToOnce route, 'sync', =>
        @subview('editRoute').dispose()
        @render()

      subview = @subview 'editRoute', new EditRouteView
        model: route
        container: $route
        containerMethod: 'after'
        templates: @templates

      $route.hide()

      @listenTo subview, 'dispose', ->
        $route.show()
