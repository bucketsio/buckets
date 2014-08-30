db = require '../../../server/lib/database'
mongoose = require 'mongoose'

Activity = require '../../../server/models/activity'

{expect} = require 'chai'
sinon = require 'sinon'

describe 'Activity', ->

  afterEach (done) ->
    for _, c of db.connection.collections
      c.remove(->)
      done()

  describe 'Validation', ->
    it 'requires an actor', (done) ->
      Activity.create {verb: {name: 'post'}, object: {objectType: 'entry', id: new mongoose.Types.ObjectId()}}, (e, activity) ->
        expect(activity).to.be.undefined
        expect(e).to.be.an 'Object'
        expect(e.errors).to.have.property 'actor.id'
        done()

    it 'requires a verb', (done) ->
      Activity.create {actor: {id: new mongoose.Types.ObjectId()}, object: {objectType: 'entry', id: new mongoose.Types.ObjectId()}}, (e, activity) ->
        expect(activity).to.be.undefined
        expect(e).to.be.an 'Object'
        expect(e.errors).to.have.property 'verb.name'
        done()

    it 'requires an object type', (done) ->
      Activity.create {actor: {id: new mongoose.Types.ObjectId()}, verb: {name: 'post'}, object: {id: new mongoose.Types.ObjectId()}}, (e, activity) ->
        expect(activity).to.be.undefined
        expect(e).to.be.an 'Object'
        expect(e.errors).to.have.property 'object.objectType'
        done()

    it 'requires an object id', (done) ->
      Activity.create {actor: {id: new mongoose.Types.ObjectId()}, verb: {name: 'post'}, object: {objectType: 'entry'}}, (e, activity) ->
        expect(activity).to.be.undefined
        expect(e).to.be.an 'Object'
        expect(e.errors).to.have.property 'object.id'
        done()

  describe 'Creation', ->
    it 'automatically populates published date if one is not provided', (done) ->
      Activity.create {actor: {id: new mongoose.Types.ObjectId()}, verb: {name: 'post'}, object: {objectType: 'entry', id: new mongoose.Types.ObjectId()}}, (e, activity) ->
        expect(activity.published.toISOString()).to.exist
        done()
