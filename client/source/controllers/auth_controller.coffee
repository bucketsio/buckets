Controller = require 'lib/controller'

LoginView = require 'views/auth/login'
ResetPasswordView = require 'views/auth/reset_password'
PasswordReset = require 'models/password_reset'
User = require 'models/user'

mediator = require('chaplin').mediator

module.exports = class AuthController extends Controller
  login: (params) ->
    if mediator.user?.get('id')
      toastr.info 'You’re already logged in.'
      @redirectTo 'buckets#dashboard'
    @view = new LoginView
      next: params.next

  resetPassword: (params) ->
    @passwordReset = new PasswordReset
      token: params.token

    @passwordReset.fetch()
      .done =>
        @listenTo @passwordReset, 'sync', (model, user) =>
          mediator.user = new User user
          @redirectTo url: '/'

        @view = new ResetPasswordView
          model: @passwordReset
      .fail =>
        toastr.error 'Password reset token is invalid or has expired.'
        @redirectTo 'buckets#dashboard'

