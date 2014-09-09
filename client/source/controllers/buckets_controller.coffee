Handlebars = require 'hbsfy/runtime'
Controller = require 'lib/controller'
MissingPageView = require 'views/missing'

BucketEditView = require 'views/buckets/edit'
DashboardView = require 'views/buckets/dashboard'
EntriesBrowser = require 'views/entries/browser'
EntryEditView = require 'views/entries/edit'

Bucket = require 'models/bucket'
Buckets = require 'models/buckets'
Fields = require 'models/fields'
Entry = require 'models/entry'
Entries = require 'models/entries'
Members = require 'models/members'
Users = require 'models/users'

mediator = require('chaplin').mediator

module.exports = class BucketsController extends Controller

  dashboard: ->
    @view = new DashboardView

  add: ->
    @adjustTitle 'New Bucket'

    newBucket = new Bucket # We don't want to destroy bucket after this
    @newFields = new Fields

    @listenToOnce newBucket, 'sync', =>
      toastr.success 'Bucket added'
      mediator.buckets.add newBucket

      @redirectTo
        url: "/#{mediator.options.adminSegment}/buckets/#{newBucket.get('slug')}/settings/fields"

    @view = new BucketEditView
      model: newBucket
      fields: @newFields

  browse: (params) ->
    bucket = mediator.buckets?.findWhere slug: params.slug

    return @bucketNotFound() unless bucket

    if params.add
      @adjustTitle 'New ' + bucket.get('singular')
    else if params.entryID
      @adjustTitle 'Edit'
    else
      @adjustTitle bucket.get('name')

    @reuse 'BucketBrowser',
      compose: (options) ->
        @entries = new Entries

        @entries.fetch( data: {until: null, bucket: bucket.get('slug'), status: ''}, processData: yes ).done =>
          @view = new EntriesBrowser
            collection: @entries
            bucket: bucket

          if options.add
            @view.loadNewEntry()
          else if options.entryID
            @view.loadEntry options.entryID

      check: (options) ->
        if @view?
          if options.add
            @view.loadNewEntry()
          else if options.entryID
            @view.loadEntry options.entryID
          else
            @view.subview('editEntry')?.dispose()

        @view? and @view.bucket.get('id') is options.bucket.get('id')

      options:
        entryID: params.entryID
        bucket: bucket
        add: params.add

  settings: (params) ->
    bucket = mediator.buckets?.findWhere slug: params.slug

    return @bucketNotFound() unless bucket

    @listenToOnce bucket, 'sync', (bucket, data) =>
      mediator.buckets.fetch(reset: yes)

      if data?.slug
        toastr.success 'Bucket saved'
        @redirectTo 'buckets#browse', slug: data.slug
      else
        toastr.success 'Bucket deleted'
        @redirectTo 'buckets#dashboard'

    @adjustTitle 'Edit ' + bucket.get('name')

    @reuse 'BucketSettings',
      compose: (options) ->
        @members = new Members bucketId: bucket.get('id')
        @users = new Users
        @fields = new Fields bucket.get('fields')

        $.when(
          @members.fetch()
          @users.fetch()
        ).done =>

          @view = new BucketEditView
            model: bucket
            fields: @fields
            members: @members
            users: @users

          @view?.setActiveTab options.activeTab if options.activeTab

      check: (options) ->
        @view?.setActiveTab options.activeTab if options.activeTab
        @view?

      options:
        activeTab: params.activeTab

  bucketNotFound: ->
    toastr.error 'Could not find that bucket.'
    @redirectTo 'buckets#dashboard'

  missing: ->
    console.log 'Page missing!', arguments
