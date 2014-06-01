Chaplin = require 'chaplin'

LoggedInLayout = require 'views/layouts/loggedin'

Buckets = require 'models/buckets'

mediator = Chaplin.mediator

module.exports = class Controller extends Chaplin.Controller

  beforeAction: (params, route) ->
    super

    if mediator.options.needsInstall and route.path isnt 'install'
      return @redirectTo url: 'install'
    
    if not mediator.user? and params.authRequired isnt no
      return @redirectTo 'auth#login', next: route.path

    else if mediator.user?.get('id')

      renderDash = =>
        @reuse 'dashboard', LoggedInLayout, 
          model: mediator.user

      if mediator.buckets
        renderDash()
      else
        mediator.buckets = new Buckets
        mediator.buckets.fetch().done renderDash
        
