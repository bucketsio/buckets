View = require 'lib/view'

tpl = require 'templates/auth/login'
FormMixin = require 'views/base/mixins/form'
mediator = require('chaplin').mediator

module.exports = class LoginView extends View
  template: tpl
  container: '#bkts-content'
  className: 'loginView'
  optionNames: View::optionNames.concat ['next']
  mixins: [FormMixin]
  events:
    'submit form': 'submitForm'
    'click [href="#forgot"]': 'clickForgot'
    'click [href="#cancel"]': 'clickCancel'

  render: ->
    super

    @$logo = @$ '#logo'
    TweenLite.from @$logo, .4,
      scale: .3
      ease: Back.easeOut

    TweenLite.from @$logo, .4,
      y: '150px'
      ease: Back.easeOut
      delay: .2

    TweenLite.from @$('fieldset'), .2,
      opacity: 0
      scale: .9
      ease: Sine.easeOut
      delay: .3

  submitForm: (e) ->

    return unless e.originalEvent

    e.preventDefault()
    $form = $(e.currentTarget)

    if $form.hasClass 'forgot'
      email = @formParams()?.username

      @submit($.post('/api/forgot', email: email))
        .error =>
          @$('input:visible').eq(0).focus()
          toastr.error 'Could not find a user with that email address.'
        .done =>
          toastr.success "A password reset email has been sent to #{email}."
          @render()
    else
      @submit($.post("/#{mediator.options.adminSegment}/checkLogin", @formParams()))
        .done -> $form.submit()
        .error =>

          # smh
          TweenLite.to @$logo, 0.15,
            transformOrigin: 'middle bottom 25' # 25 is the z-depth
            rotationY: 20
            ease: Expo.easeInOut

          TweenLite.to @$logo, 0.15,
            delay: .1
            rotationY: -20
            ease: Expo.easeInOut

          TweenLite.to @$logo, 0.15,
            delay: .25
            rotationY: 20
            ease: Expo.easeInOut

          TweenLite.to @$logo, .8,
            delay: .4
            rotationY: 0
            ease: Elastic.easeOut

  # Kinda gross but whatevs
  # We just re-render to nix for now
  clickForgot: (e) ->
    e.preventDefault()
    @$('input[name="password"]').slideUp 100
    @$('h3').text 'Enter your account email:'
    @$('.btn-primary').text 'Reset your password'
    @$('input:visible').eq(0).focus()
    @$('form').addClass('forgot')
    @$(e.currentTarget).attr('href', '#cancel').text 'Cancel'

  clickCancel: (e) ->
    e.preventDefault()
    @render()

  getTemplateData: ->
    if @next
      next: "/#{mediator.options.adminSegment}/#{@next}"
