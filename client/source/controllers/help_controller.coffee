Controller = require 'lib/controller'
HelpDocView = require 'views/help/doc'

module.exports = class HelpController extends Controller
  index: (params) ->
    console.log params.doc
    @view = new HelpDocView
      doc: params.doc
