View = require 'lib/view'

tpl = require 'templates/auth/login'
mediator = require('chaplin').mediator

module.exports = class LoginView extends View
  template: tpl
  autoRender: yes
  container: '#bkts-content'
  className: 'loginView'
  getTemplateData: ->
    if @options?.next
      _.extend super,
        next: mediator.options.adminSegment + '/' + @options.next
    else
      super
