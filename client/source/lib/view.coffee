_ = require 'underscore'

Chaplin = require 'chaplin'

module.exports = class View extends Chaplin.View
  autoRender: yes
  getTemplateFunction: -> @template
  getTemplateHTML: -> @getTemplateFunction() @getTemplateData()

  # This should be moved to a FormView mixin
  renderServerErrors: (res) =>

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