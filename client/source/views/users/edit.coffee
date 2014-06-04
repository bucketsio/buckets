_ = require 'underscore'

View = require 'lib/view'
tpl = require 'templates/users/edit'
FormMixin = require 'views/base/mixins/form'

mediator = require('chaplin').mediator

module.exports = class EditUserView extends View
  @mixin FormMixin
  template: tpl
  autoRender: yes

  events:
    'submit form': 'submitForm'
    'click [href="#remove"]': 'clickRemove'

  getTemplateData: ->
    _.extend super,
      currentUser: mediator.user?.toJSON()

  submitForm: (e) ->
    e.preventDefault()
    @submit(@model.save(@formParams(), wait: yes))

  clickRemove: (e) ->
    e.preventDefault()
    if confirm 'Are you sure?'
      @model.destroy(wait: yes).done =>
        toastr.success 'User has been removed.'
        @dispose()
