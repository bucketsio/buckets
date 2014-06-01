View = require 'lib/view'

tpl = require 'templates/auth/login'

module.exports = class LoginView extends View
  template: tpl
  autoRender: yes
  container: '#bkts-content'
  className: 'loginView'