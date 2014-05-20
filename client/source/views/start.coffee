PageView = require 'views/base/page'

tpl = require 'templates/test'

module.exports = class StartView extends PageView
  template: tpl
  
  events:
    'click button': 'clickButton'

  clickButton: (e) ->
    e.preventDefault()
    toastr.info 'Test message'