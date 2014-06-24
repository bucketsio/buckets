View = require 'lib/view'

tpl = require 'templates/fields/edit'

FormMixin = require 'views/base/mixins/form'

module.exports = class FieldEditView extends View
  template: tpl
  events:
    'submit form': 'submitForm'
    'click [href="#cancel"]': 'clickCancel'

  submitForm: (e) ->
    e.preventDefault()
    data = @formParams()
    data.slug = data.fieldSlug
    delete data.fieldSlug
    @model.set data

  clickCancel: (e) ->
    e.preventDefault()
    @dispose()

  @mixin FormMixin
