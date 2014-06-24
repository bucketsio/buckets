_ = require 'underscore'

View = require 'lib/view'
FieldEditView = require 'views/fields/edit'
Field = require 'models/field'

tpl = require 'templates/buckets/fields'
mediator = require('chaplin').mediator

module.exports = class BucketFieldsView extends View
  template: tpl

  events:
    'change select': 'addField'
    'click [href="#edit"]': 'clickEdit'
    'click [href="#remove"]': 'clickRemove'

  listen:
    'add collection': 'render'
    'remove collection': 'render'

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
      ,
        name: 'Textarea', value: 'textarea'
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
    $el = @$(e.currentTarget)

    fieldType = $el.val()

    @field = new Field
      fieldType: fieldType

    editField = @subview 'editField', new FieldEditView
      container: @$('.editField')
      model: @field

    @listenToOnce @field, 'change', (field) ->
      @subview('editField').dispose()
      @collection.add field, at: 0

  clickEdit: (e) ->
    e.preventDefault()

    idx = $(e.currentTarget).closest('tr').index() - 1
    @field = @collection.at idx

    editField = @subview 'editField', new FieldEditView
      container: @$('.editField')
      model: @field

    @listenToOnce @field, 'change', (field) ->
      @subview('editField').dispose()
      @render()

  clickRemove: (e) ->
    e.preventDefault()

    idx = $(e.currentTarget).closest('tr').index() - 1
    field = @collection.at idx

    @collection.remove field if field and confirm "Are you sure you want to remove the “#{field.get('name')}” #{field.get('fieldType')} field?"
