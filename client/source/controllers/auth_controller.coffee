Controller = require 'lib/controller'
Model = require 'lib/model'

LoginView = require 'views/auth/login'
mediator = require('chaplin').mediator

module.exports = class AuthController extends Controller
  login: (params) ->
    if mediator.user?.get('id')
      toastr.info 'You’re already logged in.'
      @redirectTo 'buckets#dashboard'
    @view = new LoginView
      model: new Model
        next: params.next
