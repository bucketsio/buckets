db = require '../../../server/lib/database'
reset = require '../../reset'
mongoose = require 'mongoose'

Activity = require '../../../server/models/activity'

{expect} = require 'chai'
sinon = require 'sinon'

describe 'Model#Activity', ->
  afterEach reset.db

  describe 'Validation', ->
    it 'requires an actor', (done) ->
      Activity.create
        verb: 'created'
        resource:
          type: 'entry'
          id: new mongoose.Types.ObjectId()

      , (e, activity) ->
        expect(activity).to.be.undefined
        expect(e).to.be.an 'Object'
        expect(e.errors).to.have.property 'actor'
        done()

    it 'requires an action', (done) ->
      Activity.create
        actor: new mongoose.Types.ObjectId()
        resource:
          type: 'entry'
          id: new mongoose.Types.ObjectId()
      , (e, activity) ->
        expect(activity).to.be.undefined
        expect(e).to.be.an 'Object'
        expect(e.errors).to.have.property 'action'
        done()

    it 'requires a resource type', (done) ->
      Activity.create
        actor: new mongoose.Types.ObjectId()
        verb: 'created'
        resource:
          id: new mongoose.Types.ObjectId()
      , (e, activity) ->
        expect(activity).to.be.undefined
        expect(e).to.be.an 'Object'
        expect(e.errors).to.have.property 'resource.type'
        done()

    it 'requires a resource id', (done) ->
      Activity.create
        actor: new mongoose.Types.ObjectId()
        action:
          name: 'post',
        resource:
          type: 'entry'
      , (e, activity) ->
        expect(activity).to.be.undefined
        expect(e).to.be.an 'Object'
        expect(e.errors).to.have.property 'resource.id'
        done()

  describe 'Creation', ->
    it 'automatically populates published date if one is not provided', (done) ->
      Activity.create
        actor: new mongoose.Types.ObjectId()
        action: 'created'
        resource:
          type: 'entry'
          id: new mongoose.Types.ObjectId()
          name: 'Test Activity'
      , (e, activity) ->
        expect(activity.publishDate.toISOString()).to.exist
        done()

    it 'automatically creates a resource.path for an Entry', (done) ->
      entryId = new mongoose.Types.ObjectId()
      Activity.create
        actor: new mongoose.Types.ObjectId()
        action: 'created'
        resource:
          type: 'entry'
          id: entryId
          name: 'Test Activity'
          bucket:
            slug: 'test'
      , (e, activity) ->
        expect(activity.resource.path).to.equal "/buckets/test/#{entryId}"
        done()

    it 'automatically creates a resource.path for a Bucket'
    it 'automatically creates a resource.path for a User'

  describe 'Activity#unlinkActivities', ->
    it 'unlinks activities'
  describe 'Activity#createForResource', ->
