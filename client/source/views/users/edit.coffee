_ = require 'underscore'

View = require 'lib/view'
tpl = require 'templates/users/edit'
FormMixin = require 'views/base/mixins/form'

mediator = require('chaplin').mediator

module.exports = class EditUserView extends View
  mixins: [FormMixin]
  template: tpl
  autoRender: yes
  region: 'contactCard'

  events:
    'submit form': 'submitForm'
    'click [href="#remove"]': 'clickRemove'

  getTemplateData: ->
    _.extend super,
      currentUser: mediator.user?.toJSON()
      isAdmin: @model.hasRole('administrator')

  submitForm: (e) ->
    e.preventDefault()
    data = @formParams()

    data.roles = @model.get('roles')

    if data.admin
      data.roles.push name: 'administrator' unless @model.hasRole('administrator')
    else
      data.roles = _.reject data.roles, (r) ->
        r.name is 'administrator'

    name = data.name

    @submit(@model.save(data, wait: yes)).done ->
      toastr.success "Saved #{name}."

  clickRemove: (e) ->
    e.preventDefault()
    if confirm 'Are you sure?'
      @model.destroy(wait: yes).done =>
        toastr.success 'User has been removed.'
        @dispose()
