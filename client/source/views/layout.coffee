Chaplin = require 'chaplin'
getSlug = require 'speakingurl'
_ = require 'underscore'

mediator = Chaplin.mediator

module.exports = class Layout extends Chaplin.Layout

  regions:
    'header': '#bkts-header'

  events:
    'keyup input[data-sluggify]': 'keyUpSluggify'
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

    # Add delegated tooltip for all help icons
    @$el.tooltip
      selector: '.show-tooltip'
      align: 'bottom'
      delay:
        show: 800
        hide: 50

    # Add Fastclick for touch devices
    Modernizr.load
      test: Modernizr.touch
      yep: "/#{mediator.options.adminSegment}/vendor/fastclick/fastclick.js"
      complete: ->
        FastClick?.attach document.body

  clickMenu: (e) ->
    e.preventDefault()
    @$('.nav-primary').toggleClass('hidden-xs').toggle().slideToggle 200
    @$('.btn-menu').toggleClass('active')

  clickMenuNav: ->
    if @$('.hidden-xs:visible').length is 0
      @$('.nav-primary').css(display: 'block').slideToggle 150, =>
        @$('.nav-primary').toggleClass('hidden-xs').toggle()

  keyUpSluggify: (e) ->
    $el = @$(e.currentTarget)

    val = $el.val()
    $target = @$("input[name=\"#{$el.data('sluggify')}\"]")
    slug = getSlug val

    $target.val slug

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
