_ = require 'underscore'
Chaplin = require 'chaplin'
PageView = require 'views/base/page'
BuildFile = require 'models/buildfile'
mediator = require 'mediator'
FormMixin = require 'views/base/mixins/form'

tpl = require 'templates/templates/editor'

handlebars = require 'hbsfy/runtime'
handlebars.registerPartial 'directory', require 'templates/templates/directory'

module.exports = class TemplateEditor extends PageView
  template: tpl
  mixins: [FormMixin]
  listen:
    'add collection': 'render'

  optionNames: PageView::optionNames.concat ['builds', 'liveFiles', 'stagingFiles', 'env', 'filename', 'env']

  className: 'templateEditor'

  events:
    'click [href="#new"]': 'clickNew'
    'click [href="#deleteFile"]': 'clickDeleteFile'
    'submit form': 'submitForm'
    'click [href="#delete"]': 'clickDeleteBuild'
    'click [href="#download"]': 'clickDownload'
    'click [href="#stage"]': 'clickStage'
    'click [href="#publish"]': 'clickPublish'
    'keydown textarea, [type=text], [type=number]': 'keyDown'
    'keyup textarea, [type=text], [type=number]': 'keyUp'

  keyUp: (e) ->
    if @cmdActive and e.which is 91
      @cmdActive = false
    e

  keyDown: (e) ->
    if @cmdActive and e.which is 13
      @$('form').submit()
    @cmdActive = e.metaKey
    e

  getTemplateData: ->
    archives = _.where @builds.toJSON(), env: 'archive'

    _.extend super,
      liveFiles: @liveFiles.getTree()
      stagingFiles: @stagingFiles.getTree()
      archives: archives
      env: @env
      stagingUrl: mediator.options.stagingUrl

  render: ->
    super
    @$code = @$('textarea.code')
    @$code.after """
      <pre class="code editor hidden"></pre>
    """
    @aceReady = new $.Deferred
    unless Modernizr.touch and not @editor
      @$code.addClass 'loading'
      Modernizr.load
        test: ace?
        nope: ["/#{mediator.options.adminSegment}/js/ace/ace.js", "/#{mediator.options.adminSegment}/js/ace/ext-modelist.js"]
        complete: @bindAceEditor
    else
      @aceReady.reject() unless @editor
      @selectTemplate @filename, @env

  bindAceEditor: =>
    return if @disposed

    ace.config.set 'basePath', "/#{mediator.options.adminSegment}/js/ace/"

    @editor = ace.edit(@$('.code.editor')[0])
    @editor.setTheme 'ace/theme/tomorrow'
    @editor.renderer.setShowGutter no

    @editorSession = @editor.getSession()
    @editorSession.setTabSize 2

    @$('pre.code, textarea.code').toggleClass 'hidden'

    @aceReady.resolve()

  selectTemplate: (filename, env='staging') ->
    @clearFormErrors()
    @env = env

    @collection = if env is 'live'
      @liveFiles
    else
      @stagingFiles

    @model = @collection.findWhere(filename: filename, build_env: env)

    unless @model
      toastr.warning "File doesn’t exist. Starting a new draft." if filename
      @model = new BuildFile
        filename: filename or ''
      @updateTemplateDisplay()
    else
      @model.fetch().done @updateTemplateDisplay

    @$('.nav-stacked li').removeClass 'active'
    @$("#env-#{env} .nav-stacked li[data-path=\"#{filename}\"]").addClass('active')

  updateTemplateDisplay: =>
    return if @disposed

    {contents, filename} = @model.toJSON()

    @$code.val contents
    @$('[name="filename"]').val filename
    @filename = filename

    @aceReady.done =>
      @modelist ?= ace.require 'ace/ext/modelist'
      mode = @modelist?.getModeForPath(filename).mode
      @editorSession.setMode mode if mode
      window.$session = @editorSession
      @editorSession.setValue contents

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

    # We want to create a new file based on their current tab
    env = if @$("ul.nav-tabs li.active").text() is 'Live'
      'live'
    else
      'staging'

    @selectTemplate(null, env)
    @$('input').focus()

  clickDeleteFile: (e) ->
    e.preventDefault()

    $li = $(e.currentTarget).closest 'li'

    collection = if $li.data('env') is 'staging'
      @stagingFiles
    else
      @liveFiles
    model = collection.findWhere filename: $li.data('path')

    if confirm 'Are you sure?'
      index = collection.indexOf model
      nextTemplate = collection.at if index+1 is collection.length then index-1 else index+1

      model.destroy(wait: yes).done =>
        @model = nextTemplate

        $li.slideUp 100, =>
          @render()

  clickDeleteBuild: (e) ->
    e.preventDefault()
    if confirm 'Are you sure you want to delete this archive?'
      $build = @$(e.currentTarget).closest('.build')
      id = $build.data('id')
      build = @builds.findWhere(id: id)

      build.destroy(wait: yes).done ->
        $build.slideUp 150

  clickStage: (e) ->
    e.preventDefault()
    buildId = @$(e.currentTarget).closest('.build').data('id')
    build = @builds.findWhere id: buildId
    if build
      build.set(env: 'staging')
      build.save({}, wait: yes)
        .done =>
          toastr.success "Restored build #{build.get('id')} to staging."
          @render()
        .error ->
          toastr.error "There was a problem restoring that build."

  clickDownload: (e) ->
    e.preventDefault()
    # todo:

  clickPublish: (e) ->
    e.preventDefault()
    build = @builds.findWhere env: 'staging'
    return toastr.error 'Error finding the build' unless build
    build.set env: 'live'
    build.save(wait: yes)
      .done =>
        toastr.success 'Published staging!'
        @builds.fetch().done => @render()
      .error ->
        toastr.error 'Couldn’t publish staging to live'

  dispose: ->
    @editor?.destroy()
    super
