PageView = require 'views/base/page'
EditRouteView = require 'views/routes/edit'

Route = require 'models/route'

tpl = require 'templates/routes/list'

module.exports = class RoutesList extends PageView
  template: tpl

  events:
    'click [href="#new"]': 'clickNew'

  clickNew: (e) ->
    e.preventDefault()
    new EditRouteView
      model: new Route