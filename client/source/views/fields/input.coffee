_ = require 'underscore'

View = require 'lib/view'

tpl = require 'templates/fields/input'
mediator = require 'mediator'

module.exports = class FieldTypeInputView extends View
  template: tpl
  region: 'user-fields'
  className: 'form-group'
  events:
    'dragover': 'hoverDropzone'
    'click .close': 'clickRemove'

  getTemplateFunction: ->
    if _.isString @template
      @cachedTplFn ?= _.template(@template).source
    else
      @template

  render: ->
    super
    return unless @model.get('fieldType') is 'cloudinary_image'

    $preview = @$('.preview')
    $progress = @$('.progress')
    $progressBar = @$('.progress-bar')

    @$input = $input = @$("input[type=file]")
      .cloudinary_fileupload
        dropzone: @$('.dropzone')
      .bind 'fileuploadstart', (e) ->
        $progress.removeClass 'hide'
      .bind 'fileuploadprogress', (e, data) ->
        percent = data.loaded/data.total*100
        $progressBar.css(width: "#{percent}%").attr 'aria-valuenow', percent
        if percent is 100
          $progressBar
            .addClass 'progress-bar-success'
            .removeClass 'active progress-bar-striped'
            .text 'Processing image…'

      .bind 'cloudinarydone', (e, data) ->
        $progressBar
          .text 'Fetching image…'

        $preview
          .css height: 0
          .show()
          .find '.preview-inner'
          .html """<img src="#{data.result.url}">"""

        imagesLoaded $preview, ->
          # Reset the progress bar
          $progress
            .addClass 'hide'
          $progressBar
            .removeClass 'progress-bar-success'
            .addClass 'progress-bar-striped active'
            .css width: 0
            .text ''
            .attr 'aria-valuenow', 0

          $preview.find('img').height()

          $input.data 'value-object', data.result
          TweenLite.to $preview, .5,
            height: $preview.find('img').height()
            ease: Sine.easeOut

  getValue: ->
    return unless @$input
    @$input.data('value-object') || @$input.val()

  hoverDropzone: ->
    clearTimeout @dropzoneTimeout if @dropzoneTimeout
    $dz = @$('.dropzone').addClass 'hover'
    @dropzoneTimeout = setTimeout ->
      $dz.removeClass 'hover'
    , 200

  clickRemove: (e) ->
    e.preventDefault()
    @$('.dropzone').slideDown()
    @$('.preview').slideUp()
    @$('input[type="hidden"]').val null
