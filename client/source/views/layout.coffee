Chaplin = require 'chaplin'

module.exports = class Layout extends Chaplin.Layout

  regions:
    'header': '#bkts-header'

  events:
    'keyup input[data-sluggify]': 'keyUpSluggify'

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

  keyUpSluggify: (e) ->
    $el = @$(e.currentTarget)
    
    val = $el.val()
    $target = @$("input[name=\"#{$el.data('sluggify')}\"]")

    slug = val.toLowerCase().replace(/\ /g, '-').replace(/[^a-zA-Z0-9-_]/g, '')
    $target.val slug