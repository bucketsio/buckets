_ = require 'underscore'

View = require 'lib/view'
tpl = require 'templates/layouts/loggedin'

mediator = require 'mediator'

module.exports = class LoggedInLayout extends View
  template: tpl
  autoRender: yes
  container: '#bkts-content'

  regions: 
    content: '.page'

  getTemplateData: ->
    _.extend super,
      buckets: mediator.buckets?.toJSON()

  initialize: ->
    super
    @listenTo mediator.buckets, 'sync', => @render()