User = require('../../../server/models/user')
Bucket = require('../../../server/models/bucket')
db = require('../../../server/lib/database')

reset = require '../../reset'

{expect, assert} = require 'chai'

describe 'Model#Bucket', ->

  before reset.db
  afterEach reset.db

  describe 'Validation', ->
    it 'requires a name and a slug', (done) ->
      bucket = new Bucket
      bucket.save (err, bucket) ->
        expect(err).to.exist
        expect(err).to.match /ValidationError/
        expect(err.errors).to.include.keys ['slug', 'name']
        done()

  describe 'Creation', ->
    it 'automatically creates a singular attribute', (done) ->
      bucket = new Bucket
        name: 'Articles'
        slug: 'articles'
      bucket.save (err, bucket) ->
        expect(err).to.not.exist
        expect(bucket).to.exist
        expect(bucket.singular).to.equal 'Article'
        done()

  describe 'Update', ->
    Entry = require '../../../server/models/entry'

    before reset.db

    user = null
    before (done) ->
      User.create {name: 'Bucketer', email: 'hello@buckets.io', password: 'S3cr3ts'}, (err, u) ->
        expect(err).to.not.exist
        user = u
        done()

    bucket = null
    beforeEach (done) ->
      bucket = new Bucket
        name: 'Articles'
        slug: 'articles'
        #fields: [
        #  fieldType: 'markdown'
        #  slug: 'body'
        #  name: 'body'
        #]
      bucket.fields.push
        fieldType: 'markdown'
        slug: 'body'
        name: 'body'
      bucket.save (err, b) ->
        expect(err).to.not.exist
        done()

    afterEach (done) -> Bucket.remove {}, -> done()

    it 'updates entry fields when slug changes', (done) ->
      Entry.create
        title: 'Some Entry'
        bucket: bucket._id
        author: user._id
        content: body: 'Bodyslam'
      , (err, entry) ->
        expect(err).to.not.exist
        expect(entry.get 'content.body').to.exist

        Bucket.findById bucket._id, (err, bucket) ->
          field = bucket.get('fields')[0]
          field.set 'slug', 'new-body'

          bucket.save (err, field) ->
            expect(err).to.not.exist
            Entry.find {bucket: bucket._id}, (err, entries) ->
              expect(err).to.not.exist
              expect(entries.length).to.not.equal 0
              for entry in entries
                expect(entry.get 'content.body').to.not.exist
                expect(entry.get 'content.new-body').to.exist
              done()

  describe '#getMembers', ->
    u = null
    b = null

    before (done) ->
      Bucket.create { name: 'Images', slug: 'images' }, (e, bucket) ->
        u = new User
          name: 'Bucketer'
          email: 'hello@buckets.io'
          password: 'S3cr3ts'
        b = bucket
        done()

    it 'returns members', (done) ->
      u.upsertRole 'contributor', b, (e, user) ->
        b.getMembers (e, users) ->
          assert.isArray(users)
          assert.lengthOf(users, 1)
          assert.equal(users[0].id, u.id)

          done()
