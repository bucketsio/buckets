_ = require 'underscore'

View = require 'lib/view'
Model = require 'lib/model'

FieldEditView = require 'views/fields/edit'
Field = require 'models/field'

tpl = require 'templates/buckets/fields'
mediator = require 'mediator'

module.exports = class BucketFieldsView extends View
  template: tpl

  events:
    'change [name="fieldType"]': 'addField'
    'click [href="#edit"]': 'clickEdit'
    'click [href="#remove"]': 'clickRemove'

  listen:
    'add collection': 'render'
    'remove collection': 'render'

  getTemplateData: ->
    fieldTypes = [
        name: 'Add a field…'
      ,
        name: 'Text', value: 'text'
      ,
        name: 'Number', value: 'number'
      ,
        name: 'Checkbox', value: 'checkbox'
      ,
        name: 'Textarea', value: 'textarea'
      ,
        name: 'Image', value: 'cloudinary_image'
      ]

    # FIXME: This currently assumes all plugins are FieldTypes...
    # plugins = _.findWhere mediator.plugins, type: 'FieldType'

    for pluginSlug, plugin of mediator.plugins
      fieldTypes.push name: plugin.name, value: pluginSlug if plugin?.name

    _.extend super, {fieldTypes: fieldTypes}

  addField: (e) ->
    $el = @$(e.currentTarget)

    fieldType = $el.val()

    field = new Field
      fieldType: fieldType

    @renderEditField field

  clickEdit: (e) ->
    e.preventDefault()

    idx = $(e.currentTarget).closest('li').index()
    field = @collection.at idx

    @renderEditField field

  renderEditField: (field) ->
    editField = @subview 'editField', new FieldEditView
      container: @$('.editField')
      model: field

    @listenToOnce field, 'change', (field) ->
      @subview('editField').dispose()
      @collection.add field, at: 0
      @render()

  clickRemove: (e) ->
    e.preventDefault()

    idx = $(e.currentTarget).closest('li').index()
    field = @collection.at idx

    {name, fieldType} = field.toJSON()

    if field and confirm "Are you sure you want to remove the “#{name}” #{fieldType} field?"
      @collection.remove field
