Chaplin = require 'chaplin'
getSlug = require 'speakingurl'
_ = require 'underscore'

module.exports = class Layout extends Chaplin.Layout

  regions:
    'header': '#bkts-header'

  events:
    'keyup input[data-sluggify]': 'keyUpSluggify'
    'click [href="#menu"]': 'clickMenu'
    'click .nav-primary a': 'clickMenuNav'
    'click .logout a': 'fadeAwayFadeAway'

  clickMenu: (e) ->
    e.preventDefault()
    @$('.nav-primary').toggleClass('hidden-xs').toggle().slideToggle 200

  clickMenuNav: ->
    if @$('.hidden-xs:visible').length is 0
      _.delay =>
        @$('.nav-primary').css(display: 'block').slideToggle 150
      , 100

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

  keyUpSluggify: (e) ->
    $el = @$(e.currentTarget)

    val = $el.val()
    $target = @$("input[name=\"#{$el.data('sluggify')}\"]")
    slug = getSlug val

    $target.val slug

  fadeAwayFadeAway: ->
    $('body').css opacity: .85
