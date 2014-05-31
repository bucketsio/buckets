_ = require 'underscore'

PageView = require 'views/base/page'

tpl = require 'templates/members/list'

module.exports = class MembersList extends PageView
  template: tpl

  optionNames: PageView::optionNames.concat ['bucket', 'users']

  listen:
    'destroy collection': 'render'
    'add collection': 'render'

  events:
    'submit .add-member': 'submitAddMember',
    'click .delete-member': 'clickDeleteMember'

  submitAddMember: (e) ->
    e.preventDefault()

    data = @$el.formParams(false)
    u = _.clone(@users.get(data.user).attributes)
    u.bucketId = @bucket.id
    u.role = data.role

    @collection.create(u)

  clickDeleteMember: (e) ->
    e.preventDefault()

    if confirm 'Are you sure?'
      model = @collection.findWhere _id: @$(e.currentTarget).closest('.member').data('memberId')
      model.destroy().done =>
        toastr.success "#{model.get('name')} has been removed from #{@bucket.name}"

  getTemplateData: ->
    _.extend super,
      bucket: @bucket.toJSON()
      users: _.reject @users.toJSON(), (u) => !!@collection.get(u._id)
