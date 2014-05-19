Controller = require 'lib/controller'
FirstUserView = require 'views/install/firstuser'

module.exports = class InstallController extends Controller

  start: ->
    @view = new FirstUserView