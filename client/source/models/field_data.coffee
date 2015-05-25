Model = require 'lib/model'

module.exports = class FieldData extends Model
  defaults:
    data: value: null

  getData: ->
    @data

  getValue: (path) ->
    path = 'value' unless path
    @get('data')[path]

  setValue: (path, value) ->
    unless value
      value = path
      path = 'value'

    @get('data')[path] = value
    # TODO should trigger some event, not sure about Chaplin
    #@trigger 'change', {path: path, value: value}
    @
