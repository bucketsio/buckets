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
