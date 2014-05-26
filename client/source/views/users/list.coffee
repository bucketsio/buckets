PageView = require 'views/base/page'

tpl = require 'templates/users/list'

module.exports = class UsersList extends PageView
  template: tpl