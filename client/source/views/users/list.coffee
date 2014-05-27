PageView = require 'views/base/page'

EditUserView = require 'views/users/edit'
User = require 'models/user'

tpl = require 'templates/users/list'

module.exports = class UsersList extends PageView
  template: tpl

  events:
    'click [href="#add"]': 'clickAdd'

  clickAdd: (e) ->
    e.preventDefault()
    @subview 'newUser', new EditUserView
      model: new User
      container: @$el