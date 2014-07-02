View = require 'lib/view'

tpl = require 'templates/auth/login'
FormMixin = require 'views/base/mixins/form'
mediator = require('chaplin').mediator

module.exports = class LoginView extends View
  template: tpl
  container: '#bkts-content'
  className: 'loginView'
  optionNames: View::optionNames.concat ['next']

  events:
    'submit form': 'submitForm'

  render: ->
    super
    TweenLite.from @$('#logo'), .4,
      scale: .3
      ease: Back.easeOut

    TweenLite.from @$('#logo'), .4,
      y: '150px'
      ease: Back.easeOut
      delay: .2

    TweenLite.from @$('fieldset'), .2,
      opacity: 0
      scale: .9
      ease: Sine.easeOut
      delay: .3

  submitForm: (e) ->
    @$btn = @$('.ladda-button').ladda()
    @$btn.ladda('start')

  getTemplateData: ->
    if @next
      next: "/#{mediator.options.adminSegment}/#{@next}"

  @mixin FormMixin
