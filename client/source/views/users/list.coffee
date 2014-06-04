_ = require 'underscore'
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

  regions:
    'contactCard': '.detail'

  getTemplateData: ->
    _.extend super,
      items: @collection.toJSON()

  render: ->
    super
    @selectUser @model if @model

  clickAdd: (e) ->
    e.preventDefault()
    newUser = new User
    @$('.nav li').removeClass('active')

    @listenToOnce newUser, 'sync', =>
      @collection.add newUser
      @render()

    @selectUser newUser

  selectUser: (user) ->
    @model = user
    idx = @collection.indexOf @model

    if @model
      @$('.nav li').eq(idx).addClass('active').siblings().removeClass('active') if idx >= 0

      @subview 'editUser', new EditUserView
        model: @model

  clickEdit: (e) ->
    e.preventDefault()

    $el = @$(e.currentTarget)
    idx = $el.parent('li').index()
    @selectUser @collection.at(idx)
