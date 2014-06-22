_ = require 'underscore'

PageView = require 'views/base/page'

tpl = require 'templates/entries/list'

module.exports = class EntriesList extends PageView
  template: tpl

  optionNames: PageView::optionNames.concat ['bucket']

  getTemplateData: ->
    _.extend super,
      bucket: @bucket.toJSON()

  render: ->
    super

    @$('.center, .entry').each (i, el) ->

      TweenLite.from el, .2,
        opacity: 0
        # scale: .99
        delay: i * .05
        y: 15
        ease: Cubic.easeInOut
        # delay: .15
        # ease: Elastic.easeOut
        # easeParams: [.5]
