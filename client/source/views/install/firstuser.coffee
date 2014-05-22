PageView = require 'views/base/page'
_ = require 'underscore'
tpl = require 'templates/install/firstuser'

module.exports = class FirstUserView extends PageView
  template: tpl
  
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
    ).done ->
      toastr.success 'User created!'