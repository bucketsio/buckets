View = require 'lib/view'
mediator = require('chaplin').mediator
_ = require 'underscore'

module.exports = class PageView extends View
  autoRender: yes
  container: '#bkts-content'

  getTemplateData: ->
    _.extend super,
      user: mediator.user?.toJSON()