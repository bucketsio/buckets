Controller = require 'lib/controller'

Templates = require 'models/templates'
TemplateEditor = require 'views/templates/editor'

module.exports = class TemplatesController extends Controller
  edit: ->
    @adjustTitle 'Templates'
    
    @templates = new Templates

    @templates.fetch().done =>
      @view = new TemplateEditor
        collection: @templates