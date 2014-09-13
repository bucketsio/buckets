Chaplin = require 'chaplin'
_ = require 'underscore'

mediator = Chaplin.mediator

module.exports = class Layout extends Chaplin.Layout

  regions:
    'header': '#bkts-header'

  events:
    'click [href="#menu"]': 'clickMenu'
    'click #logo a': 'clickLogo'
    'click .nav-primary a': 'clickMenuNav'
    'click .logout a': 'fadeAwayFadeAway'

  initialize: ->
    super

    toastr.options =
      debug: false
      positionClass: "toast-bottom-right"
      showDuration: 100
      hideDuration: 100
      timeOut: 2100
      extendedTimeOut: 1000
      showEasing: 'swing'
      hideEasing: 'swing'
      showMethod: 'slideDown'
      hideMethod: 'slideUp'

    # Add Fastclick for touch devices
    Modernizr.load
      test: Modernizr.touch
      yep: "/#{mediator.options.adminSegment}/vendor/fastclick/fastclick.js"
      complete: ->
        FastClick?.attach document.body

    # Add delegated tooltip for all help icons
    @$el.tooltip
      selector: '.show-tooltip'
      align: 'bottom'
      delay:
        show: 800
        hide: 50

  clickMenu: (e) ->
    @$nav ?= @$('.nav-primary')
    @$btnMenu ?= @$('.btn-menu')

    e.preventDefault()
    @$nav.toggleClass('hidden-xs').toggle().slideToggle 200
    @$btnMenu.toggleClass('active')

  clickMenuNav: ->
    @$nav ?= @$('.nav-primary')
    @$btnMenu ?= @$('.btn-menu')

    @$btnMenu.removeClass 'active'

    if $(window).width() <= 768

      @$nav.css(display: 'block').slideToggle 150, =>
        @$nav.toggleClass('hidden-xs').toggle()

  fadeAwayFadeAway: ->
    $('body').css opacity: .85

  clickLogo: (e) ->
    e.preventDefault()

    @$logoImg ?= $('#logo img')

    TweenLite.killTweensOf @$logoImg

    TweenLite.fromTo @$logoImg, .6,
      scaleX: .75
    ,
      scaleX: 1
      ease: Elastic.easeOut
    TweenLite.fromTo @$logoImg, .6,
      scaleY: .75
    ,
      scaleY: 1
      delay: .03
      ease: Elastic.easeOut

    Chaplin.utils.redirectTo 'buckets#dashboard'
