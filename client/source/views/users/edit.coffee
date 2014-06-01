_ = require 'underscore'

View = require 'lib/view'
tpl = require 'templates/users/edit'

mediator = require('chaplin').mediator

module.exports = class EditUserView extends View
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
    
    data = @$el.formParams(no)
    @model.save(data, wait: yes).fail(@renderServerErrors).done =>
      @dispose()

  clickRemove: (e) ->
    e.preventDefault()
    @model.destroy(wait: yes).done =>
      toastr.success 'User has been removed.'
      @dispose()