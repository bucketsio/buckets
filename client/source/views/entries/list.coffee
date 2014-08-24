_ = require 'underscore'

CollectionView = require 'lib/collection_view'
EntryRowView = require 'views/entries/row'

tpl = require 'templates/entries/list'

module.exports = class EntriesList extends CollectionView
  template: tpl
  itemView: EntryRowView
  useCssAnimation: yes
  region: 'list'
  optionNames: CollectionView::optionNames.concat ['bucket']

  getTemplateData: ->
    _.extend super, bucket: @bucket.toJSON()

  itemRemoved: (entry) ->
    if id = entry?.get('id')
      @$("[data-entry-id=\"#{id}\"]").slideUp
        duration: 200
        easing: 'easeInExpo'
        complete: -> $(@).parent().remove()

    if @collection.length is 0
      @$fallback.show()

  itemAdded: (entry) ->
    thing = super
    if id = entry?.get('id')
      $el = @$("[data-entry-id=\"#{id}\"]").hide()
      _.defer =>
        $el.slideDown
          duration: 200
          easing: 'easeOutExpo'
