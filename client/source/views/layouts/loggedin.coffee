View = require 'lib/view'
tpl = require 'templates/layouts/loggedin'

module.exports = class LoggedInLayout extends View
  template: tpl
  autoRender: yes
  container: '#bkts-content'

  regions:
    content: '.page'