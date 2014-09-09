_ = require 'underscore'
Handlebars = require 'hbsfy/runtime'
Chaplin = require 'chaplin'

PageView = require 'views/base/page'
EntriesList = require 'views/entries/list'
Entry = require 'models/entry'

EntryEditView = require 'views/entries/edit'

tpl = require 'templates/entries/browser'
mediator = require 'mediator'

module.exports = class EntriesBrowser extends PageView
  template: tpl
  optionNames: PageView::optionNames.concat ['bucket']

  regions:
    'detail': '.entry-detail'
    'list': '.entries'

  listen:
    'all collection': 'checkLength'

  getTemplateData: ->
    _.extend super,
      bucket: @bucket.toJSON()
      items: @collection?.toJSON()

  render: ->
    super
    @subview 'EntryList', new EntriesList
      collection: @collection
      bucket: @bucket

  loadEntry: (entryID) ->
    @model = @collection.findWhere(id: entryID) or new Entry id: entryID

    @model.fetch().done =>
      @$('.entry').removeClass('active').filter("[data-entry-id=#{@model.get('id')}]").addClass('active')
      @model.set
        publishDate: Handlebars.helpers.simpleDateTime @model.get('publishDate')
      , silent: yes

      @model.on 'sync', @modelSaved

      @renderDetailView()

  loadNewEntry: ->
    @$('.entry.active').removeClass('active')

    @model = new Entry
      author: mediator.user.toJSON()

    @model.on 'sync', @modelSaved

    @renderDetailView()

  modelSaved: (entry, newData) =>
    if newData?.id
      @model.set newData
      toastr.success "You saved “#{entry.get('title')}”"
      @collection.add @model
    else
      toastr.success "You deleted “#{entry.get('title')}”"

    Chaplin.utils.redirectTo 'buckets#browse', slug: @bucket.get('slug')

  renderDetailView: ->
    sv = @subview 'editEntry', new EntryEditView
      model: @model
      bucket: @bucket
      author: @model.get('author') or mediator.user.toJSON()

    model = @model
    @listenToOnce sv, 'dispose', =>
      model.off 'sync', @modelSaved

  checkLength: ->
    unless @disposed
      @$('.hasEntries').toggleClass 'hidden', @collection.length is 0
