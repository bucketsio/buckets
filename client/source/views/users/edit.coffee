_ = require 'underscore'

View = require 'lib/view'
tpl = require 'templates/users/edit'
FormMixin = require 'views/base/mixins/form'

mediator = require('chaplin').mediator

module.exports = class EditUserView extends View
  @mixin FormMixin

  template: tpl
  autoRender: yes
  region: 'contactCard'

  events:
    'submit form': 'submitForm'
    'click [href="#remove"]': 'clickRemove'

  getTemplateData: ->
    _.extend super,
      currentUser: mediator.user?.toJSON()
      isAdmin: _.findWhere(@model.get('roles'), name: 'administrator')

  submitForm: (e) ->
    e.preventDefault()
    data = @formParams()
    data.roles = @model.get('roles')
    data.roles = data.roles.push name: 'administrator' if data.admin and not _.findWhere(@model.get('roles'), name: 'administrator')
    @submit(@model.save(data, wait: yes))

  clickRemove: (e) ->
    e.preventDefault()
    if confirm 'Are you sure?'
      @model.destroy(wait: yes).done =>
        toastr.success 'User has been removed.'
        @dispose()
