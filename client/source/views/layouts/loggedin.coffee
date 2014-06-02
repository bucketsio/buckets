_ = require 'underscore'

View = require 'lib/view'
tpl = require 'templates/layouts/loggedin'

mediator = require('chaplin').mediator

module.exports = class LoggedInLayout extends View
  template: tpl
  autoRender: yes
  container: '#bkts-content'

  events:
    'click .nav-primary a': 'clickNav'

  regions:
    content: '.page'

  getTemplateData: ->
    _.extend super,
      buckets: mediator.buckets?.toJSON()

  initialize: ->
    super
    @listenTo mediator.buckets, 'sync add', => @render()

  clickNav: (e) ->
    $el = @$(e.currentTarget)
    $el.closest('li').addClass('active').siblings().removeClass('active')
