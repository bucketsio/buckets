_ = require 'underscore'

View = require 'lib/view'
FormMixin = require 'views/base/mixins/form'
tpl = require 'templates/members/list'

module.exports = class MembersList extends View
  template: tpl
  mixins: [FormMixin]
  optionNames: View::optionNames.concat ['bucket', 'users']

  listen:
    'destroy collection': 'render'
    'add collection': 'render'

  events:
    'submit .add-member': 'submitAddMember',
    'click .delete-member': 'clickDeleteMember'

  submitAddMember: (e) ->
    e.preventDefault()

    data = @$el.formParams(false)
    u = @users.get(data.user).toJSON()
    u.bucketId = @bucket.id
    u.role = data.role

    @collection.create(u)

  clickDeleteMember: (e) ->
    e.preventDefault()

    if confirm 'Are you sure?'
      model = @collection.findWhere id: @$(e.currentTarget).closest('.member').data('memberId')
      model.destroy().done =>
        toastr.success "#{model.get('name')} has been removed from #{@bucket.name}"

  getTemplateData: ->
    _.extend super,
      bucket: @bucket.toJSON()
      # Remove users which are already members
      users: _.compact @users.map (user) =>
        user.toJSON() unless @collection.get(user.get('id'))? or user.hasRole('administrator')
