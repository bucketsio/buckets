PageView = require 'views/base/page'

tpl = require 'templates/install/firstuser'

module.exports = class FirstUserView extends PageView
  template: tpl
  
  render: ->
    super
    @$btn = @$('button[type=submit]').ladda()

  events:
    'submit form': 'submitForm'

  submitForm: (e) ->
    e.preventDefault()
    @$btn.ladda 'start'