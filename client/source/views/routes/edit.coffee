_ = require 'underscore'

View = require 'lib/view'
FormMixin = require 'views/base/mixins/form'

tpl = require 'templates/routes/edit'

module.exports = class EditRouteView extends View
  @mixin FormMixin
  template: tpl
  className: 'routeEdit'
  optionNames: View::optionNames.concat ['templates']

  events:
    'submit form': 'submitForm'
    'click [href="#cancel"]': 'clickCancel'

  getTemplateData: ->
    _.extend super,
      templates: @templates?.toJSON()

  submitForm: (e) ->
    e.preventDefault()
    @submit @model.save(@formParams(), wait: yes)

  clickCancel: (e) ->
    e.preventDefault()
    @dispose()
