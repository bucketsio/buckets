_ = require 'underscore'

PageView = require 'views/base/page'

tpl = require 'templates/entries/list'

module.exports = class EntriesList extends PageView
  template: tpl

  optionNames: PageView::optionNames.concat ['bucket']

  getTemplateData: ->
    _.extend super,
      bucket: @bucket.toJSON()
