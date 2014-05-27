Controller = require 'lib/controller'

Template = require 'models/template'
Templates = require 'models/templates'

TemplateEditor = require 'views/templates/editor'

module.exports = class TemplatesController extends Controller

  edit: (params) ->
    @adjustTitle 'Templates'

    unless params.filename
      return @redirectTo 'templates#edit', filename: 'index'
    
    @templates = new Templates
    @newTemplate = new Template

    @templates.fetch().done =>

      @view = new TemplateEditor
        collection: @templates
        filename: params.filename
        newTemplate: @newTemplate