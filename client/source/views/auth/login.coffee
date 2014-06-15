View = require 'lib/view'

tpl = require 'templates/auth/login'
FormMixin = require 'views/base/mixins/form'
mediator = require('chaplin').mediator

module.exports = class LoginView extends View
  template: tpl
  container: '#bkts-content'
  className: 'loginView'

  events:
    'submit form': 'submitForm'

  submitForm: ->
    @$btn?.ladda?('start')

  optionNames: View::optionNames.concat ['next']

  getTemplateData: ->
    if @next
      next: "/#{mediator.options.adminSegment}/#{@next}"

  @mixin FormMixin
