Controller = require 'lib/controller'
StartInstallView = require 'views/install/start'

module.exports = class InstallController extends Controller

  start: ->
    @view = new StartInstallView