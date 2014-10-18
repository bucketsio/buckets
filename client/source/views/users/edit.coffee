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
    'click [href="#importDropbox"]': 'clickImportDropbox'
    'click [href="#deploy"]': 'clickDeploy'
    'click [href="#disconnectDropbox"]': 'disconnectDropbox'

  getTemplateData: ->
    _.extend super,
      currentUser: mediator.user?.toJSON()
      isAdmin: @model.hasRole('administrator')
      dropboxEnabled: mediator.options?.dropboxEnabled

  submitForm: (e) ->
    e.preventDefault()
    data = @formParams()

    data.roles = @model.get('roles')

    if data.admin
      data.roles.push name: 'administrator' unless @model.hasRole('administrator')
    else
      data.roles = _.reject data.roles, (r) ->
        r.name is 'administrator'
    data.previewMode = data.previewMode?
    name = data.name

    @submit(@model.save(data, wait: yes)).done ->
      toastr.success "Saved #{name}."

  clickRemove: (e) ->
    e.preventDefault()
    if confirm 'Are you sure?'
      @model.destroy(wait: yes).done =>
        toastr.success 'User has been removed.'
        @dispose()

  disconnectDropbox: ->
    e.preventDefault()

  clickImportDropbox: (e) ->
    e.preventDefault()
    $.post '/api/dropbox/import'
      .done ->
        toastr.success 'Your personal preview environment has been updated.'

  clickDeploy: (e) ->
    e.preventDefault()
    $.post '/api/builds'
      .done ->
        toastr.success 'The website has been updated.'
