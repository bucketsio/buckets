Controller = require 'lib/controller'
Users = require 'models/users'
BasicSettingsView = require 'views/settings/basic'
UsersList = require 'views/users/list'
module.exports = class SettingsController extends Controller
  basic: ->
    @adjustTitle 'Settings'
    @view = new BasicSettingsView
  
  users: ->
    @adjustTitle 'Users'
    @users = new Users

    @users.fetch().done =>
      
      @view = new UsersList
        collection: @users