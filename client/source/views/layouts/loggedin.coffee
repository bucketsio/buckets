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
    _.delay =>
      @collapseNav()


    , 3000

    $sidebar = @$('#bkts-sidebar')
    openTimeout = null
    @$('#bkts-sidebar').hover =>
      clearTimeout openTimeout if openTimeout
      openTimeout = setTimeout =>
        @openNav()
      , 200
    , =>
      clearTimeout openTimeout if openTimeout
      openTimeout = setTimeout =>
        @collapseNav()
      , 800



  checkNav: (controller, params, route) ->
    @collapseNav()

    @$('.nav-primary li').removeClass 'active'

    return unless route?.path

    for link in @$navLinks
      $link = $(link)
      href = $link.attr('href')
      newURL = "/#{mediator.options.adminSegment}/#{route.path}"
      if newURL.substr(0, href.length) is href
        $link.parent().addClass('active')
        break

  collapseNav: ->
    $logo = @$('#logo')
    $body = $('.loggedInView')
    $menuBtn = @$('.btn-menu').css display: 'block'

    TweenLite.to $logo, 1,
      scale: .6
      x: -10
      ease: Bounce.easeOut
      delay: .08

    TweenLite.to @$('#bkts-ftr'), .15,
      opacity: 0
      ease: Sine.easeIn

    TweenLite.to @$('#bkts-sidebar'), .25,
      width: 60
      ease: Sine.easeIn
      delay: .1

    TweenLite.to $body, .25,
      marginLeft: 60
      ease: Sine.easeIn
      delay: .1

    TweenLite.to @$('#bkts-sidebar li > a'), .25,
      opacity: 0
      x: -90
      opacity: 0
      delay: .1
      ease: Sine.easeIn

  openNav: ->
    $body = $('.loggedInView')
    $logo = @$('#logo')
    TweenLite.to @$('#bkts-sidebar'), .3,
      width: 240
      ease: Sine.easeOut

    TweenLite.to $body, .3,
      marginLeft: 240
      ease: Sine.easeOut

    TweenLite.to @$('#bkts-sidebar li > a'), .25,
      opacity: 1
      x: 0
      delay: .1
      ease: Sine.easeOut

    TweenLite.to $logo, 1,
      scale: 1
      x: 0
      ease: Bounce.easeOut
      delay: .08

    TweenLite.to @$('#bkts-ftr'), .15,
      opacity: 1
      ease: Sine.easeOut
      delay: .4
