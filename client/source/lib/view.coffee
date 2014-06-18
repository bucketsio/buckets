_ = require 'underscore'

Chaplin = require 'chaplin'

module.exports = class View extends Chaplin.View
  autoRender: yes
  getTemplateFunction: -> @template
  getTemplateHTML: -> @getTemplateFunction() @getTemplateData()

  dispose: ->
    @trigger 'dispose'
    super
