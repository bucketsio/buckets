View = require 'lib/view'

tpl = require 'templates/auth/reset'
FormMixin = require 'views/base/mixins/form'

module.exports = class ResetPasswordView extends View
  template: tpl
  container: '#bkts-content'
  className: 'loginView'
  mixins: [FormMixin]

  events:
    'submit form': 'submitForm'

  submitForm: (e) ->
    e.preventDefault()
    @submit @model.save @formParams()
