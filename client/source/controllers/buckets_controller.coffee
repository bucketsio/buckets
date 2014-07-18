Handlebars = require 'hbsfy/runtime'
Controller = require 'lib/controller'
MissingPageView = require 'views/missing'

BucketEditView = require 'views/buckets/edit'
DashboardView = require 'views/buckets/dashboard'
EntriesList = require 'views/entries/list'
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

  listEntries: (params) ->
    bucket = mediator.buckets?.findWhere slug: params.slug

    return @bucketNotFound() unless bucket
    @adjustTitle bucket.get('name')

    @entries = new Entries

    @entries.fetch( data: {bucket: bucket.get('id')}, processData: yes ).done =>
      @view = new EntriesList
        collection: @entries
        bucket: bucket

  addEntry: (params) ->
    bucket = mediator.buckets?.findWhere slug: params.slug

    return @bucketNotFound() unless bucket

    @adjustTitle 'New ' + bucket.get('singular')

    @entry = new Entry

    @listenToOnce @entry, 'sync', =>
      toastr.success 'Entry added'
      @redirectTo 'buckets#listEntries', slug: bucket.get('slug')

    @view = new EntryEditView
      model: @entry
      bucket: bucket
      user: mediator.user.toJSON()

  editEntry: (params) ->
    bucket = mediator.buckets?.findWhere slug: params.slug

    if bucket and params.entryID
      @adjustTitle 'New ' + bucket.get('singular')

      @entry = new Entry _id: params.entryID

      @entry.fetch().done =>

        @entry.set 'publishDate', Handlebars.helpers.simpleDateTime @entry.get('publishDate')

        @listenToOnce @entry, 'sync', (entry, newData) =>
          if newData._id
            toastr.success "You saved “#{entry.get('title')}”"
          else
            toastr.success "You deleted “#{entry.get('title')}”"

          @redirectTo 'buckets#listEntries', slug: bucket.get('slug')

        @view = new EntryEditView
          model: @entry
          bucket: bucket
          user: @entry.get('author') or mediator.user.toJSON()

  settings: (params) ->
    bucket = mediator.buckets?.findWhere slug: params.slug

    return @bucketNotFound unless bucket

    @listenToOnce bucket, 'sync', (bucket, data) =>
      mediator.buckets.fetch(reset: yes)

      if data.slug
        toastr.success 'Bucket saved'
        @redirectTo 'buckets#listEntries', slug: data.slug
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
