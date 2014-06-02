_ = require 'underscore'

View = require 'lib/view'

tpl = require 'templates/routes/edit'

module.exports = class EditRouteView extends View
  template: tpl
  autoRender: yes
  className: 'routeEdit'

  events:
    'submit form': 'submitForm'
    'click [href="#cancel"]': 'clickCancel'

  submitForm: (e) ->
    e.preventDefault()
    data = @$el.formParams(no)
    @model.save(data)

  render: ->
    super

    _.defer =>
      @$('input').get(0).focus()

  clickCancel: (e) ->
    e.preventDefault()
    @dispose()
