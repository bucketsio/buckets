PageView = require 'views/base/page'
Template = require 'models/template'
_ = require 'underscore'
mediator = require('chaplin').mediator
FormMixin = require 'views/base/mixins/form'

tpl = require 'templates/templates/editor'

module.exports = class TemplateEditor extends PageView
  template: tpl
  mixins: [FormMixin]
  listen:
    'sync collection': 'render'

  events:
    'click [href="#new"]': 'clickNew'
    'click [href="#delete"]': 'clickDelete'
    'submit form': 'submitForm'

  getTemplateData: ->
    _.extend super,
      items: @collection.toJSON()

  render: ->
    super
    @$code = @$('textarea.code')
    @$code.after """
      <pre class="code editor hidden"></pre>
    """
    unless Modernizr.touch
      @$code.addClass 'loading'
      Modernizr.load
        test: ace?
        nope: "/#{mediator.options.adminSegment}/js/ace/ace.js"
        complete: @bindAceEditor
    else
      @selectTemplate @model.get('filename')

  bindAceEditor: =>
    return if @disposed

    ace.config.set 'basePath', "/#{mediator.options.adminSegment}/js/ace/"
    @editor = ace.edit(@$('.code.editor')[0])
    @editor.setTheme 'ace/theme/tomorrow'
    @editor.renderer.setShowGutter no

    @editorSession = @editor.getSession()
    @editorSession.setMode 'ace/mode/handlebars'
    @editorSession.setTabSize 2

    @$('pre.code, textarea.code').toggleClass 'hidden'

    @selectTemplate @model.get('filename')

  selectTemplate: (filename) ->
    if filename
      @model = @collection.findWhere(filename: filename)

      if @model
        contents = @model.get 'contents'
        idx = @collection.indexOf @model
        @$('.input-group li').eq(idx).addClass('active').siblings().removeClass('active')
      else
        @model = new Template
          filename: filename

    else
      @model = new Template
      contents = ''
      @$('.input-group li').removeClass 'active'

    @$code.val contents
    @$('[name="filename"]').val filename
    @editorSession?.setValue contents
    @clearFormErrors()
    @$('.notForIndex').toggleClass 'hide', filename is 'index'

  submitForm: (e) ->
    e.preventDefault()
    @$code.val(@editorSession.getValue()) if @editorSession?

    data = @formParams()

    @submit(@model.save data).done( =>
      toastr.success "Saved Template “#{@model.get('filename')}”"
      @collection.add @model
    ).error (res) =>
      if compileErr = res?.responseJSON?.errors?.contents
        if compileErr.line
          @editor.renderer.setShowGutter yes
          @editor.getSession().setAnnotations [
            row: compileErr.line - 1
            text: compileErr.message
            type: 'error'
          ]

  clickNew: (e) ->
    e.preventDefault()
    @selectTemplate()
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
