Chaplin = require 'chaplin'

module.exports = class Layout extends Chaplin.Layout

  regions:
    'header': '#bkts-header'

  initialize: ->
    super

    toastr.options =
      debug: false
      positionClass: "toast-top-full-width"
      showDuration: 100
      hideDuration: 300
      timeOut: 2100
      extendedTimeOut: 1000
      showEasing: 'swing'
      hideEasing: 'linear'
      showMethod: 'slideDown'
      hideMethod: 'slideUp'