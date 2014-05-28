View = require 'lib/view'

tpl = require 'templates/routes/edit'

module.exports = class EditRouteView extends View
  template: tpl
  autoRender: yes

  events:
    'submit form': 'submitForm'

  submitForm: (e) ->
    e.preventDefault()
    data = @$el.formParams(no)
    @model.save(data)

  render: ->
    super
    @$('input').get(0).focus()