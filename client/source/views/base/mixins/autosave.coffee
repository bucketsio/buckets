_ = require 'underscore'

module.exports =
  startAutosave: (e) ->
    return unless e.type == 'keydown' || e.data?.action == 'removeText'
    return if e.keyCode? in [16, 17, 18, 91, 93] # shift, ctrl, alt, l-command, r-command

    (_.debounce @autosave.bind(@), 2 * 1000)()

  autosave: ->
    @model.set('status', 'draft')
    @model.set('autosave', true)
    @model.save(@formParams()).done =>
      @model?.set('autosave', false)
