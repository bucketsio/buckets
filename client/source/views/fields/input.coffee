_ = require 'underscore'

View = require 'lib/view'

tpl = require 'templates/fields/input'

module.exports = class FieldTypeInputView extends View
  template: tpl
  region: 'user-fields'

  getTemplateFunction: ->
    if _.isString @template
      @cachedTplFn ?= _.template(@template).source
    else
      @template
