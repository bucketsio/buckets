Chaplin = require 'chaplin'

helpers = require 'views/helpers'

module.exports = class Layout extends Chaplin.Layout
  initialize: ->
    super

    toastr.options =
      debug: false
      positionClass: "toast-top-full-width"
      # onclick: null
      showDuration: 100
      hideDuration: 200
      # hideDuration: 1000
      timeOut: 2000
      extendedTimeOut: 1000
      showEasing: 'swing'
      hideEasing: 'linear'
      showMethod: 'slideDown'
      hideMethod: 'slideUp'