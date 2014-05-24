Controller = require 'lib/controller'

LoginView = require 'views/auth/login'

module.exports = class AuthController extends Controller
  login: ->
    @view = new LoginView