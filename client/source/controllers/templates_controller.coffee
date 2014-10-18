Controller = require 'lib/controller'
Templates = require 'models/templates'
Builds = require 'models/builds'
Template = require 'models/template'
TemplateEditor = require 'views/templates/editor'

module.exports = class TemplatesController extends Controller

  edit: (params) ->
    unless params.filename
      return @redirectTo 'templates#edit', filename: 'index.hbs', env: 'staging'

    @adjustTitle 'Templates'

    @reuse 'Templates',
      compose: ->
        @builds = new Builds

        @stagingFiles = new Templates
        @liveFiles = new Templates
        @liveFiles.build_env = 'live'
        $.when(
          @liveFiles.fetch()
          @stagingFiles.fetch()
          @builds.fetch()
        ).done =>
          @view = new TemplateEditor
            stagingFiles: @stagingFiles
            liveFiles: @liveFiles
            builds: @builds
            env: params.env
            filename: params.filename

          @view.selectTemplate params.filename, params.env

      check: (options) ->
        if options.filename isnt @view.filename or options.env isnt @view.env
          @view.selectTemplate options.filename, options.env

        @view? and @stagingFiles? and @liveFiles? and @builds?

      options:
        filename: params.filename
        env: params.env
