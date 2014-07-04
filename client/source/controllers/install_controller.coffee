Controller = require 'lib/controller'
Install = require 'models/install'
User = require 'models/user'
FirstUserView = require 'views/install/firstuser'

mediator = require('chaplin').mediator

module.exports = class InstallController extends Controller

  firstuser: ->
    @adjustTitle 'Install'

    newInstall = new Install

    @view = new FirstUserView
      model: newInstall

    newInstall.on 'sync', (model, user) =>
      mediator.user = new User user
      mediator.options.needsInstall = no

      @redirectTo url: '/'
