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
    'click [href="#edit"]': 'clickEdit'

  listen:
    'add collection': 'render'

  getTemplateData: ->
    _.extend super,
      fieldTypes: [
        name: 'Add a field…'
      ,
        name: 'Text', value: 'text'
      ,
        name: 'Number', value: 'number'
      ,
        name: 'Checkbox', value: 'checkbox'
      ,
        name: 'Color', value: 'color'
      ,
        name: 'File', value: 'file'
      # ,
      #   name: 'Date/time', value: 'datetime'
      # ,
      #   name: 'Markdown', value: 'markdown'
      # ,
      #   name: 'Email', value: 'email'
      # ,
      #   name: 'HTML Editor', value: 'html'
      # ,
      #   name: 'Relationship', value: 'relationship'
      # ,
      #   name: 'Location', value: 'location'
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

  clickEdit: (e)->
    e.preventDefault()

    idx = $(e.currentTarget).closest('li').index()
    @field = @collection.at idx

    editField = @subview 'editField', new FieldEditView
      container: @$el
      model: @field

    @listenTo @field, 'change', (field) ->
      @render()

  @mixin FormMixin
