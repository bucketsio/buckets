PageView = require 'views/base/page'

tpl = require 'templates/auth/login'

module.exports = class LoginView extends PageView
  template: tpl