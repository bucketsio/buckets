Chaplin = require 'chaplin'

mediator = Chaplin.mediator

module.exports = class Controller extends Chaplin.Controller

  beforeAction: (params, route) ->
    super

    console.log route

    if mediator.options.needsInstall and route.path isnt 'install'
      return @redirectTo url: 'install'
    
    if not mediator.user? and params.authRequired isnt no
      return @redirectTo url: 'login'