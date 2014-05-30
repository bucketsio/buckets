Controller = require 'lib/controller'
MissingPageView = require 'views/missing'

BucketEditView = require 'views/buckets/edit'
EntriesList = require 'views/entries/list'
EntryEditView = require 'views/entries/edit'

Bucket = require 'models/bucket'
Buckets = require 'models/buckets'
Entry = require 'models/entry'
Entries = require 'models/entries'

mediator = require('chaplin').mediator

module.exports = class BucketsController extends Controller

  dashboard: ->
    @buckets = new Buckets

    $.when(
      @buckets.fetch()
    ).done =>
      @view = null
      # @view = new BucketList

  add: ->    
    @adjustTitle 'New Bucket'

    newBucket = new Bucket

    @listenToOnce newBucket, 'sync', =>
      toastr.success 'Bucket added'
      mediator.buckets.add newBucket
      @redirectTo url: '/'

    @view = new BucketEditView
      model: newBucket

  listEntries: (params) ->
    bucket = mediator.buckets?.findWhere slug: params.slug

    if bucket
      @adjustTitle bucket.get('name')

      @entries = new Entries

      @entries.fetch( data: {bucket: bucket.get('id')}, processData: yes ).done =>
        @view = new EntriesList
          collection: @entries
          bucket: bucket

  addEntry: (params) ->
    bucket = mediator.buckets?.findWhere slug: params.slug

    if bucket
      @adjustTitle 'New ' + bucket.get('singular')

      @entry = new Entry

      @listenToOnce @entry, 'sync', =>
        toastr.success 'Entry added'
        @redirectTo 'buckets#listEntries', slug: bucket.get('slug')

      @view = new EntryEditView
        model: @entry
        bucket: bucket
        user: mediator.user

  editEntry: (params) ->
    bucket = mediator.buckets?.findWhere slug: params.slug

    if bucket and params.entryID
      @adjustTitle 'New ' + bucket.get('singular')

      @entry = new Entry _id: params.entryID

      @entry.fetch().done =>

        @listenToOnce @entry, 'sync', (entry, newData) =>
          if newData._id
            toastr.success 'Entry saved'
          else
            toastr.success 'Entry deleted'
            
          @redirectTo 'buckets#listEntries', slug: bucket.get('slug')

        @view = new EntryEditView
          model: @entry
          bucket: bucket
          user: mediator.user

  settings: (params) ->
    bucket = mediator.buckets?.findWhere slug: params.slug

    if bucket
      @adjustTitle 'Edit ' + bucket.get('name')

      bucket.once 'sync', =>
        toastr.success 'Bucket saved'
        mediator.buckets.fetch(reset: yes)
        @redirectTo url: '/'

      @view = new BucketEditView
        model: bucket

  missing: ->
    console.log 'Page missing!', arguments