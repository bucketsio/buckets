View = require 'lib/view'

tpl = require 'templates/auth/login'
FormMixin = require 'views/base/mixins/form'
mediator = require('chaplin').mediator

module.exports = class LoginView extends View
  @mixin FormMixin

  template: tpl
  autoRender: yes
  container: '#bkts-content'
  className: 'loginView'

  optionNames: View::optionNames.concat ['next']

  getTemplateData: ->
    if @next
      next: "/#{mediator.options.adminSegment}/#{@next}"
