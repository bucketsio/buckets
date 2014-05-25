Controller = require 'lib/controller'
MissingPageView = require 'views/missing'

BucketEditView = require 'views/buckets/edit'

Bucket = require 'models/bucket'
Buckets = require 'models/buckets'

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

    @newBucket.once 'sync', ->
      toastr.success 'Bucket added'
      @redirectTo url: '/'

    @view = new BucketEditView
      model: @newBucket

  missing: ->
    console.log 'Page missing!', arguments