Controller = require 'lib/controller'
FirstUserView = require 'views/install/firstuser'

module.exports = class InstallController extends Controller

  start: ->
    @adjustTitle 'Install'
    @view = new FirstUserView