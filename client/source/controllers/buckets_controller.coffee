Controller = require 'lib/controller'
MissingPageView = require 'views/missing'

BucketEditView = require 'views/buckets/edit'
EntriesList = require 'views/entries/list'

Bucket = require 'models/bucket'
Buckets = require 'models/buckets'

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

    @newBucket = new Bucket

    @newBucket.once 'sync', =>
      toastr.success 'Bucket added'
      mediator.buckets.add @newBucket
      @redirectTo url: '/'

    @view = new BucketEditView
      model: @newBucket

  listEntries: (params) ->
    bucket = mediator.buckets?.findWhere slug: params.slug
    @view = new EntriesList
      bucket: bucket

  addEntry: ->
    # @entry = new Entry

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