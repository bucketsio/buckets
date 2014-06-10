Controller = require 'lib/controller'
User = require 'models/user'
FirstUserView = require 'views/install/firstuser'

mediator = require('chaplin').mediator

module.exports = class InstallController extends Controller

  firstuser: ->
    @adjustTitle 'Install'

    newUser = new User
      roles: [{name: 'administrator'}]

    @view = new FirstUserView
      model: newUser

    newUser.on 'sync', =>
      mediator.options.needsInstall = no
      @redirectTo url: '/'
