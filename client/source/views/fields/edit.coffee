_ = require 'underscore'

View = require 'lib/view'
FormMixin = require 'views/base/mixins/form'
FieldTypeSettingsView = require 'views/fields/settings'

mediator = require 'mediator'
tpl = require 'templates/fields/edit'

module.exports = class FieldEditView extends View
  template: tpl
  mixins: [FormMixin]
  events:
    'submit form': 'submitForm'
    'click [href="#cancel"]': 'clickCancel'

  regions:
    'settings': '.settings'

  render: ->
    super

    if @model.get('fieldType') in ['text', 'textarea', 'checkbox', 'number', 'cloudinary_image']
      @renderSettings()
    else
      # Otherwise ensure the plugin is loaded and see if one exists
      mediator.loadPlugin(@model.get('fieldType')).done @renderSettings

  renderSettings: =>
    configOptions = region: 'settings', model: @model
    plugin = mediator.plugins[@model.get('fieldType')]

    if plugin
      if _.isFunction plugin.settingsView
        SettingsView = plugin.settingsView
      else if _.isString plugin.settingsView
        configOptions.template = plugin.settingsView
        SettingsView = FieldTypeSettingsView
    else
      SettingsView = FieldTypeSettingsView

    @subview "settings_#{@model.get('slug')}", new FieldTypeSettingsView configOptions

  submitForm: (e) ->
    e.preventDefault()

    data = @formParams()
    data.fieldType = @model.get('fieldType')
    data.slug = data.fieldSlug
    delete data.fieldSlug
    data.settings = @$('.settings').formParams()
    @model.set data

  clickCancel: (e) ->
    e.preventDefault()
    @dispose()
