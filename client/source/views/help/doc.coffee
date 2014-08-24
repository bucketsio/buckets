PageView = require 'views/base/page'
mediator = require 'mediator'

module.exports = class HelpDocView extends PageView
  optionNames: PageView::optionNames.concat ['doc']
  className: 'col-md-8'
  render: ->
    super
    @$el.load "/#{mediator.options.adminSegment}/help-html/#{@doc}", ->
      console.log 'done loading', arguments
