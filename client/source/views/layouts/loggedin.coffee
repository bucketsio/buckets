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
      version: mediator.options?.version

  initialize: ->
    super
    @subscribeEvent 'dispatcher:dispatch', @checkNav
    @listenTo mediator.buckets, 'sync add', => @render()

    @throttledCheckSize = _.throttle @checkSize, 1000, trailing: yes
    $(window).on 'resize', @throttledCheckSize

  render: ->
    super

    @$('#bkts-sidebar li').each (i, el) ->
      TweenLite.from el, .2,
        y: '30px'
        opacity: 0
        ease: Sine.easeOut
        delay: i * .01

    @openTimeout = null
    @$('#bkts-sidebar').hover =>
      clearTimeout @openTimeout if @openTimeout
      @openTimeout = setTimeout @openNav, 50
    , =>
      clearTimeout @openTimeout if @openTimeout
      @openTimeout = setTimeout @collapseNav, 50

    setTimeout @collapseNav, 300

  checkNav: (controller, params, route) ->
    @$navLinks ?= @$('.nav-primary a')

    if route.previous and not @$('#bkts-sidebar:hover').length
      @openTimeout = setTimeout =>
        @collapseNav()
      , 200

    @$('.nav-primary li').removeClass 'active'

    return unless route?.path

    for link in @$navLinks
      $link = $(link)
      href = $link.attr('href')
      newURL = "/#{mediator.options.adminSegment}/#{route.path}"
      if newURL.substr(0, href.length) is href
        $link.parent().addClass('active')
        break

  collapseNav: =>
    return unless $(window).width() > 768

    $logo = @$('#logo')
    $view = $('.loggedInView')

    $menuBtn = @$('.btn-menu').css display: 'block'

    @killTweens()

    TweenLite.to $logo, .5,
      scale: .6
      x: -9
      ease: Back.easeOut
      delay: .1

    TweenLite.to @$('#bkts-ftr'), .15,
      opacity: 0
      ease: Sine.easeIn

    TweenLite.to @$('#bkts-sidebar'), .25,
      width: 60
      ease: Sine.easeIn
      overflow: 'hidden'
      delay: .1

    TweenLite.to $view, .25,
      marginLeft: 60
      ease: Sine.easeIn
      delay: .1

    TweenLite.to @$('#bkts-sidebar li'), .25,
      opacity: .5
      x: -200
      y: 0
      opacity: 0
      delay: .1
      ease: Sine.easeIn

  openNav: =>
    return unless $(window).width() > 768

    @killTweens()

    $view = $('.loggedInView')
    $logo = @$('#logo')

    TweenLite.to @$('#bkts-sidebar'), .3,
      width: 240
      ease: Sine.easeOut
      overflow: 'scroll'

    TweenLite.to $view, .3,
      marginLeft: 240
      ease: Sine.easeOut

    for $link, i in @$('#bkts-sidebar li')
      TweenLite.to $link, .18 - .01*i,
        opacity: 1
        x: 0
        y: 0
        delay: .04 * i - i * .008
        ease: Sine.easeOut

    TweenLite.to $logo, .5,
      scale: 1
      x: 0
      ease: Back.easeOut

    TweenLite.to @$('#bkts-ftr'), .15,
      opacity: 1
      ease: Sine.easeOut
      delay: .4

  killTweens: ->
    TweenLite.killTweensOf $('.loggedInView, #logo, #bkts-sidebar, #bkts-sidebar li, #bkts-ftr')

  checkSize: =>
    if $(window).width() <= 768
      @killTweens()
      TweenLite.set $('.loggedInView, #logo, #bkts-sidebar, #bkts-sidebar li, #bkts-ftr'),
        clearProps: 'all'
    else
      @killTweens()
      @collapseNav()

  dispose: ->
    $(window).off 'resize', @throttledCheckSize
    super
