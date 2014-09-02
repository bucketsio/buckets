_ = require 'underscore'

View = require 'lib/view'

tpl = require 'templates/fields/input'
mediator = require 'mediator'

module.exports = class FieldTypeInputView extends View
  template: tpl
  region: 'user-fields'
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

    $preview = @$('.preview')
    $dropzone = @$('.dropzone')
    $progress = @$('.progress')
    $progressBar = @$('.progress-bar')

    if @model.get('value')
      $dropzone.hide()
    else
      $preview.hide()

    @$("input[type=file]")
      .cloudinary_fileupload
        dropzone: @$('.dropzone')
      .bind 'fileuploadstart', (e) ->
        $progress.removeClass 'hide'
      .bind 'fileuploadprogress', (e, data) ->
        percent = data.loaded/data.total*100
        $progressBar.css(width: "#{percent}%").attr 'aria-valuenow', percent
      .bind 'cloudinarydone', (e, data) =>
        $preview
          .css height: 0
          .show()
          .find '.preview-inner'
          .html $.cloudinary.image data.result.public_id,
            format: data.result.format
            version: data.result.version
            crop: 'fit'
            width: 600
            height: 300
            quality: 50
        $progressBar.text 'Processing image…'


        imagesLoaded $preview, =>
          # Reset the progress bar
          $progress
            .addClass 'hide'
          $progressBar
            .css width: 0
            .text ''
            .attr 'aria-valuenow', 0

          $preview.find('img').height()

          @$('[type="hidden"]').val data.result.public_id
          TweenLite.to $preview, .5,
            height: @$('.preview img').height()
            ease: Sine.easeOut

          $dropzone.slideUp 200

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
