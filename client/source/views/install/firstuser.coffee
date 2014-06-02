_ = require 'underscore'

View = require 'lib/view'

tpl = require 'templates/install/firstuser'

module.exports = class FirstUserView extends View
  template: tpl
  container: '#bkts-content'
  autoRender: yes

  render: ->
    super
    @$btn = @$('button[type=submit]').ladda()
    _.defer =>
      @$('.form-control').eq(0).focus()

  events:
    'submit form': 'submitForm'

  submitForm: (e) ->
    e.preventDefault()

    data = @$(e.currentTarget).formParams false

    btn = @$btn.ladda 'start'

    @model.save(data).always( ->
      btn.ladda 'stop'
    ).fail(@renderServerErrors).done ->
      toastr.success 'User created!'
