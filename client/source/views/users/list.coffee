PageView = require 'views/base/page'

EditUserView = require 'views/users/edit'
User = require 'models/user'

tpl = require 'templates/users/list'

module.exports = class UsersList extends PageView
  template: tpl

  listen:
    'sync collection': 'render'

  events:
    'click [href="#add"]': 'clickAdd'
    'click .users a': 'clickEdit'

  clickAdd: (e) ->
    e.preventDefault()
    newUser = new User

    @subview 'editUser', new EditUserView
      model: newUser
      container: @$('.detail')

    @listenToOnce newUser, 'sync', =>
      @collection.add newUser
      @render()

  clickEdit: (e) ->
    e.preventDefault()

    $el = @$(e.currentTarget)
    idx = $el.parent('li').index()

    user = @collection.at idx

    @subview 'editUser', new EditUserView
      model: user
      container: @$('.detail')