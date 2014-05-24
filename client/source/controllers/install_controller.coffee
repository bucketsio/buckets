Controller = require 'lib/controller'
User = require 'models/user'
FirstUserView = require 'views/install/firstuser'
StartView = require 'views/start'

module.exports = class InstallController extends Controller

  start: ->
    @adjustTitle 'Welcome'

    @view = new StartView

  firstuser: ->
    @adjustTitle 'Install'

    newUser = new User

    @view = new FirstUserView
      model: newUser

    newUser.on 'sync', => 
      mediator.options.needsInstall = no
      @redirectTo url: '/'