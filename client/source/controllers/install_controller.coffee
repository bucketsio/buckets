Controller = require 'lib/controller'
User = require 'models/user'
FirstUserView = require 'views/install/firstuser'

module.exports = class InstallController extends Controller

  start: ->
    newUser = new User
    @adjustTitle 'Install'
    @view = new FirstUserView
      model: newUser

    newUser.on 'save', ->
      toastr.info 'Now redirect to the Dashboard...'