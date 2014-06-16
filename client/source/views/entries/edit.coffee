_ = require 'underscore'

PageView = require 'views/base/page'
FormMixin = require 'views/base/mixins/form'
tpl = require 'templates/entries/edit'

module.exports = class EntryEditView extends PageView

  template: tpl
  optionNames: PageView::optionNames.concat ['bucket', 'user']

  events:
    'submit form': 'submitForm'
    'click [href="#delete"]': 'clickDelete'

  getTemplateData: ->
    fields = @bucket.get('fields')
    _.map fields, (field) =>
      field.value = @model.get(field.slug)
      field

    _.extend super,
      bucket: @bucket?.toJSON()
      user: @user?.toJSON()
      fields: fields
      newTitle: "New #{@bucket.get('singular')}"

  submitForm: (e) ->
    e.preventDefault()
    @submit @model.save(@formParams(), wait: yes)

  clickDelete: (e) ->
    e.preventDefault()

    if confirm 'Are you sure?'
      @model.destroy(wait: yes)

  @mixin FormMixin
