_ = require 'underscore'

View = require 'lib/view'
tpl = require 'templates/layouts/loggedin'

mediator = require('chaplin').mediator

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
    @subscribeEvent 'dispatcher:dispatch', @checkNav
    @listenTo mediator.buckets, 'sync add', => @render()

  render: ->
    super
    @$navLinks = @$('.nav-primary a')

  checkNav: (controller, params, route) ->
    return unless route?.path

    for link in @$navLinks
      $link = $(link)
      href = $link.attr('href')
      newURL = "/#{mediator.options.adminSegment}/#{route.path}"

      if newURL.substr(0, href.length + 1) is href
        $link.parent().addClass('active').siblings().removeClass('active')
        break
