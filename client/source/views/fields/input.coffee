View = require 'lib/view'

tpl = require 'templates/fields/input'

module.exports = class FieldTypeInputView extends View
  template: tpl
  region: 'user-fields'
  # getTemplateFunction: -> @template
  getValue: ->
    data = @$el.formParams no
    simpleValue = data[@model.get('slug')]
    if simpleValue?
      simpleValue
    else
      data
