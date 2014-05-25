Chaplin = require 'chaplin'

LoggedInLayout = require 'views/layouts/loggedin'

mediator = Chaplin.mediator

module.exports = class Controller extends Chaplin.Controller

  beforeAction: (params, route) ->
    super

    if mediator.options.needsInstall and route.path isnt 'install'
      return @redirectTo url: 'install'
    
    if not mediator.user? and params.authRequired isnt no
      return @redirectTo url: 'login'

    else if mediator.user?.get('id')
      @reuse 'dashboard', LoggedInLayout, model: mediator.user