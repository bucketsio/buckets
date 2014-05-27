PageView = require 'views/base/page'
_ = require 'underscore'

tpl = require 'templates/templates/editor'

module.exports = class TemplateEditor extends PageView
  template: tpl

  listen:
    'sync collection': 'render'

  events:
    'click [href="#new"]': 'clickNew'
    'click [href="#delete"]': 'clickDelete'
    'submit form': 'submitForm'

  getTemplateData: ->
    _.extend super,
      items: @collection.toJSON()

  initialize: (@options) ->
    @model = @collection.findWhere filename: @options?.filename
    @model ?= @options.newTemplate.clone()
    super
    
  submitForm: (e) ->
    e.preventDefault()
    data = @$(e.currentTarget).formParams(no)
    @model.save(data).done =>
      toastr.success 'Saved Template'
      @collection.add @model

  clickNew: (e) ->
    e.preventDefault()
    @model = @options.newTemplate.clone()
    @render()
    @$('input').focus()

  clickDelete: (e) ->
    e.preventDefault()
    index = @collection.indexOf @model
    nextTemplate = @collection.at if index+1 is @collection.length then index-1 else index+1

    @model.destroy(wait: yes).done =>
      @model = nextTemplate
      @render()