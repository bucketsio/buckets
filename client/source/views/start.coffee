View = require 'lib/view'

tpl = require 'templates/test'

module.exports = class StartView extends View
  autoRender: yes
  tpl: tpl
  container: '#bkts-content'
  
  events:
    'click button': 'clickButton'

  clickButton: (e) ->
    e.preventDefault()
    toastr.success 'woot'