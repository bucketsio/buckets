db = require '../../../server/lib/database'
logger = require '../../../server/lib/logger'
reset = require '../../reset'
mongoose = require 'mongoose'

Activity = require '../../../server/models/activity'
Bucket = require '../../../server/models/bucket'
Entry = require '../../../server/models/entry'

{expect} = require 'chai'
sinon = require 'sinon'

describe 'Model#Activity', ->
  @timeout 3000

  bucket = null
  entry = null

  before reset.db

  beforeEach (done) ->
    userId = new mongoose.Types.ObjectId()

    Bucket.create
      name: 'Articles'
      slug: 'articles'
    , (e, _bucket) ->
      bucket = _bucket

      Entry.create
        title: 'Test Article'
        bucket: bucket._id
        author: userId
        status: 'live'
        publishDate: '2 days ago'
      , (e, _entry) ->
        entry = _entry
        done()

  afterEach reset.db

  describe 'Validation', ->
    it 'requires an actor', (done) ->
      Activity.create
        verb: 'created'
      , (e, activity) ->
        expect(activity).to.be.undefined
        expect(e).to.be.an 'Object'
        expect(e.errors).to.have.property 'actor'
        done()

    it 'requires an action', (done) ->
      Activity.create
        actor: new mongoose.Types.ObjectId()
      , (e, activity) ->
        expect(activity).to.be.undefined
        expect(e).to.be.an 'Object'
        expect(e.errors).to.have.property 'action'
        done()

    it 'requires a resource name', (done) ->
      Activity.create
        actor: new mongoose.Types.ObjectId()
        action: 'created'
      , (e, activity) ->
        expect(activity).to.be.undefined
        expect(e).to.be.an 'Object'
        expect(e.errors).to.have.property 'resource.name'
        done()

  describe 'Creation', ->
    it 'automatically populates published date if one is not provided', (done) ->
      Activity.create
        actor: new mongoose.Types.ObjectId()
        action: 'created'
        resource:
          type: 'entry'
          name: 'Test Activity'
      , (e, activity) ->
        expect(activity.publishDate.toISOString()).to.exist
        done()

    it 'automatically creates a resource.path for an Entry', (done) ->
      Activity.create
        actor: new mongoose.Types.ObjectId()
        action: 'created'
        resource:
          kind: 'article'
          name: 'Test Article'
          entry: entry
          bucket: bucket
      , (e, activity) ->
        Activity.populate activity, 'resource.entry resource.bucket', (e, activity) ->
          expect(activity.resource.path).to.equal "/buckets/articles/#{entry.id}"
          done()

    it 'automatically creates a resource.path for a Bucket'
    it 'automatically creates a resource.path for a User'

  describe 'Activity#unlinkActivities', ->
    it 'unlinks activities'
  describe 'Activity#createForResource', ->
