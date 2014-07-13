_ = require 'underscore'

View = require 'lib/view'

tpl = require 'templates/fields/settings'

module.exports = class FieldTypeSettingsView extends View
  optionNames: View::optionNames.concat ['template']

  template: tpl

  getTemplateFunction: ->
    if _.isString @template
      @cachedTplFn ?= _.template(@template)
    else
      @template
