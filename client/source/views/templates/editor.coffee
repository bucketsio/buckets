PageView = require 'views/base/page'
_ = require 'underscore'
mediator = require('chaplin').mediator

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

  render: ->
    super()
    @$code = @$('textarea.code')
    Modernizr.load
      load: ["/#{mediator.options.adminSegment}/js/ace/ace.js"]
      complete: @bindAceEditor

  bindAceEditor: =>
    ace.config.set 'basePath', "/#{mediator.options.adminSegment}/js/ace/"
    @editor = ace.edit(@$('.code.editor')[0])
    @editor.setTheme 'ace/theme/tomorrow'
    @editor.renderer.setShowGutter no

    @editorSession = @editor.getSession()
    @editorSession.setMode 'ace/mode/handlebars'

    @editorSession.setValue @$code.val()

  submitForm: (e) ->
    e.preventDefault()
    @$code.val(@editorSession.getValue()) if @editorSession?
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

    if confirm 'Are you sure?'
      index = @collection.indexOf @model
      nextTemplate = @collection.at if index+1 is @collection.length then index-1 else index+1

      @model.destroy(wait: yes).done =>
        @model = nextTemplate
        @render()

  dispose: ->
    @editor?.destroy()
    super
