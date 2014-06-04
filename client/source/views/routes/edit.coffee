_ = require 'underscore'

View = require 'lib/view'

tpl = require 'templates/routes/edit'

module.exports = class EditRouteView extends View
  template: tpl
  className: 'routeEdit'

  events:
    'submit form': 'submitForm'
    'click [href="#cancel"]': 'clickCancel'

  submitForm: (e) ->
    e.preventDefault()
    @submit @model.save(@formParams(), wait: yes)

  clickCancel: (e) ->
    e.preventDefault()
    @dispose()
