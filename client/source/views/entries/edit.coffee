_ = require 'underscore'

PageView = require 'views/base/page'
FormMixin = require 'views/base/mixins/form'
tpl = require 'templates/entries/edit'

module.exports = class EntryEditView extends PageView
  @mixin FormMixin

  template: tpl
  optionNames: PageView::optionNames.concat ['bucket', 'user']

  events:
    'submit form': 'submitForm'
    'click [href="#delete"]': 'clickDelete'

  getTemplateData: ->
    _.extend super,
      bucket: @bucket?.toJSON()
      user: @user?.toJSON()

  submitForm: (e) ->
    e.preventDefault()
    @submit @model.save(@formParams(), wait: yes)

  clickDelete: (e) ->
    if confirm 'Are you sure?'
      @model.destroy(wait: yes)
