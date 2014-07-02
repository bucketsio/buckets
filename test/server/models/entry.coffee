db = require '../../../server/lib/database'

Entry = require '../../../server/models/entry'
Bucket = require '../../../server/models/bucket'

{expect} = require 'chai'

describe 'Entry', ->
  beforeEach (done) ->
    for _, c of db.connection.collections
      c.remove(->)
      done()

  afterEach (done) ->
    db.connection.db.dropDatabase done

  describe 'Validation', ->
    it 'requires a bucket', (done) ->
      Entry.create {title: 'Some Entry'}, (e, entry) ->
        expect(entry).to.be.undefined
        expect(e).to.be.an 'Object'
        expect(e).to.have.deep.property 'errors.bucket'
        done()

  describe 'Creation', ->
    bucketId = null

    beforeEach (done) ->
      Bucket.create {name: 'Articles', slug: 'articles'}, (e, bucket) ->
        bucketId = bucket._id
        done()

    it 'parses dates from strings', (done) ->
      Entry.create {title: 'New Entry', publishDate: 'tonight at 9pm', bucket: bucketId}, (e, entry) ->
        expected = new Date
        expected.setHours(21, 0, 0, 0)

        expect(expected.toISOString()).equal(entry.publishDate.toISOString())
        done()

    it 'generates a smart slug', (done) ->
      Entry.create {title: 'Resumés & CVs', bucket: bucketId}, (e, entry) ->
        expect(entry.slug).to.equal 'resumes-and-cvs'
        done()
