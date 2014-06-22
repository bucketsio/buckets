Controller = require 'lib/controller'
User = require 'models/user'
Users = require 'models/users'
BasicSettingsView = require 'views/settings/basic'
UsersList = require 'views/users/list'

module.exports = class SettingsController extends Controller
  basic: ->
    @adjustTitle 'Settings'
    @view = new BasicSettingsView

  users: (params) ->

    @adjustTitle 'Users'

    @reuse 'UsersList',
      compose: ->
        @users = new Users

        @users.fetch().done =>
          if params.email
            @user = @users.findWhere email: params.email
          else
            @user = null

          @view = new UsersList
            collection: @users
            model: @user

      check: (options) ->
        if options.email isnt @view.model?.get('id')
          @view.selectUser @users.findWhere(email: options.email)
        @view?
      options:
        email: params.email

    if @view?.model
      console.log 'MODEL!!!'
