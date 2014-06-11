_ = require 'underscore'

module.exports =
  render: ->
    # Automatically focus the first visible input
    _.defer =>
      @$('.form-control:visible').eq(0).focus()

      # Prepare any submit buttons for Ladda
      @$btn = @$('.ladda-button').ladda()

  formParams: ->
    # Uses jQuery formParams, but don't try to convert number values to numbers, etc.
    @$el.formParams no

  submit: (promise) ->
    @$btn.ladda 'start'

    promise.always(
      @$btn.ladda 'stop'
    ).fail(
      _.bind(@renderServerErrors, @)
    )

  renderServerErrors: (res) ->

    # First let's get rid of the old ones
    @$('.help-block').remove()
    @$('.has-error').removeClass('has-error')

    if errors = res?.responseJSON?.errors
      _.each errors, (error) =>
        if error.type is 'required'
          message = '<span class="label label-danger">Required</span>'
        else
          message = error.message

        @$ """[name="#{error.path}"]"""
          .closest '.form-group'
          .find('.help-block').remove().end()
          .addClass 'has-error'
          .append """
            <span class="help-block">#{message}</span>
          """

      @$('.has-error').eq(0).find('[name]').focus()
