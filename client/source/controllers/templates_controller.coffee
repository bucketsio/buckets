Controller = require 'lib/controller'
Templates = require 'models/templates'
TemplateEditor = require 'views/templates/editor'

module.exports = class TemplatesController extends Controller

  edit: (params) ->
    unless params.filename
      return @redirectTo 'templates#edit', filename: 'index'

    @adjustTitle 'Templates'

    @reuse 'Templates',
      compose: ->
        @templates = new Templates
        @templates.fetch().done =>
          @template = @templates.findWhere filename: params.filename

          @view = new TemplateEditor
            collection: @templates
            model: @template

      check: (options) ->
        if options.filename isnt @view.model.get('filename')
          @view.selectTemplate options.filename
        @view? and @templates?

      options:
        filename: params.filename
