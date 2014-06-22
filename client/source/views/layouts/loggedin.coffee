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

    @navTimeline ?= new TimelineLite
    @navTimeline.staggerFrom @$('.nav-primary li'), .15,
      y: '30px'
      opacity: 0
      ease: Back.easeOut
    , .02

    @navTimeline.play()

  checkNav: (controller, params, route) ->
    @$('.nav-primary li').removeClass 'active'

    return unless route?.path

    for link in @$navLinks
      $link = $(link)
      href = $link.attr('href')
      newURL = "/#{mediator.options.adminSegment}/#{route.path}"
      if newURL.substr(0, href.length) is href
        $link.parent().addClass('active')
        break
