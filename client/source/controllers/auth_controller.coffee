Controller = require 'lib/controller'
Model = require 'lib/model'

LoginView = require 'views/auth/login'

module.exports = class AuthController extends Controller
  login: (params) ->
    @view = new LoginView
      model: new Model
        next: params.next