_ = require 'underscore'
PageView = require 'views/base/page'

tpl = require 'templates/buckets/dashboard'

module.exports = class DashboardView extends PageView
  template: tpl

  getTemplateData: ->
    _.extend super,
      activities: @collection.toJSON()