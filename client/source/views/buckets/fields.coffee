_ = require 'underscore'

View = require 'lib/view'
FormMixin = require 'views/base/mixins/form'
FieldEditView = require 'views/fields/edit'
Field = require 'models/field'

tpl = require 'templates/buckets/fields'
mediator = require('chaplin').mediator

module.exports = class BucketFieldsView extends View
  template: tpl
  events:
    'change select': 'addField'

  listen:
    'add collection': 'render'

  getTemplateData: ->
    _.extend super,
      fieldTypes: [
        name: 'Add a field'
      ,
        name: 'Text', value: 'text'
      ,
        name: 'HTML Editor', value: 'html'
      ,
        name: 'Number', value: 'number'
      ,
        name: 'Checkbox', value: 'checkbox'
      ,
        name: 'Date/time', value: 'datetime'
      ,
        name: 'Email', value: 'email'
      ,
        name: 'File', value: 'file'
      ,
        name: 'Relationship', value: 'relationship'
      ,
        name: 'Color', value: 'color'
      ,
        name: 'Location', value: 'location'
      ]

  addField: (e) ->
    $el = @$(e.currentTarget).hide()

    fieldType = $el.val()

    @field = new Field
      fieldType: fieldType

    editField = @subview 'editField', new FieldEditView
      container: @$el
      model: @field

    @listenTo @field, 'change', (field) ->
      @collection.add field

  @mixin FormMixin
