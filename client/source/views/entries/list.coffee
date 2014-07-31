_ = require 'underscore'
Handlebars = require 'hbsfy/runtime'
Chaplin = require 'chaplin'

PageView = require 'views/base/page'
Entry = require 'models/entry'

EntryEditView = require 'views/entries/edit'

tpl = require 'templates/entries/list'

mediator = require 'mediator'

module.exports = class EntriesList extends PageView
  template: tpl

  optionNames: PageView::optionNames.concat ['bucket']

  regions:
    'detail': '.entry-detail'

  getTemplateData: ->
    _.extend super,
      bucket: @bucket.toJSON()
      items: @collection?.toJSON()

  loadEntry: (entryID) ->
    @model = new Entry _id: entryID

    @model.fetch().done =>

      @model.set 'publishDate', Handlebars.helpers.simpleDateTime @model.get('publishDate')

      @listenToOnce @model, 'sync', (entry, newData) =>
        if newData._id
          toastr.success "You saved “#{entry.get('title')}”"
        else
          toastr.success "You deleted “#{entry.get('title')}”"

        Chaplin.utils.redirectTo 'buckets#browse', slug: @bucket.get('slug')

      @renderDetailView()

  loadNewEntry: ->
    @model = new Entry
      author: mediator.user.toJSON()

    @listenToOnce @model, 'sync', =>
      toastr.success "You added #{@model.get('title')}"

      # Gross-ness to get list refresh for now
      # Should separate list into separate view
      @collection.fetch({data: {bucket: @bucket.get('id')}}, {processData: yes, reset: yes}).done =>
        @render()
        _.defer =>
          Chaplin.utils.redirectTo 'buckets#browse', slug: @bucket.get('slug')

    @renderDetailView()

  renderDetailView: ->
    @subview 'editEntry', new EntryEditView
      model: @model
      bucket: @bucket
      author: @model.get('author') or mediator.user.toJSON()
