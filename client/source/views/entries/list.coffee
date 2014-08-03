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
    if id = entry?.get('_id')
      @$("[data-entry-id=\"#{id}\"]").parent().slideUp
        duration: 250
        ease: Expo.easeIn
        complete: -> $(@).remove()
