mongoose = require 'mongoose'
mongoosastic = require 'mongoosastic'
_ = require 'underscore'
chrono = require 'chrono-node'
async = require 'async'
getSlug = require 'speakingurl'
url = require 'url'

config = require '../config'
db = require '../lib/database'

# Add a parser to Chrono to understand "now"
# A bit hacky because Chrono doesn't support ms yet
chrono.parsers.NowParser = (text, ref, opt) ->

  parser = chrono.Parser(text, ref, opt)

  parser.pattern = -> /now/i
  parser.extract = (text, index) ->
    mentioned_text = text.substr(index).match(/now/i)[0];

    now = new Date()
    new chrono.ParseResult
      referenceDate : ref
      text : mentioned_text
      index: index
      start:
        year: now.getFullYear()
        month: now.getMonth()
        day: now.getDate()
        hour: now.getHours()
        minute: now.getMinutes()
        second: now.getSeconds() + 1
        millisecond: now.getMilliseconds()

  parser

Schema = mongoose.Schema

entrySchema = new Schema
  title:
    type: String
    required: yes
    es_boost: 3.0
    es_indexed: yes
  description:
    type: String
    es_boost: 2.0
    es_indexed: yes
  slug:
    type: String
    es_indexed: yes
  status:
    type: String
    enum: ['draft', 'live', 'pending', 'rejected']
    required: yes
    default: 'draft'
  lastModified:
    type: Date
    es_type: 'date'
    default: Date.now
  publishDate:
    type: Date
    es_type: 'date'
    default: Date.now
  createdDate:
    type: Date
    es_type: 'date'
    default: Date.now
  author:
    type: Schema.Types.ObjectId
    ref: 'User'
    required: yes
  bucket:
    type: Schema.Types.ObjectId
    ref: 'Bucket'
    required: yes
  keywords:
    type: [String]
    es_indexed: yes
    es_boost: 2.0
  content:
    type: {}
    default: {}
    es_type : 'object'
    es_indexed: yes
    es_boost: 2.0

entrySchema.pre 'save', (next) ->
  @lastModified = Date.now()
  next()

entrySchema.pre 'validate', (next) ->
  @slug ?= getSlug @title

  mongoose.model('Bucket').findOne _id: @bucket, (err, bkt) =>

    @invalidate 'bucket', 'Must belong to a bucket' unless bkt

    for field in bkt?.fields or []
      if field.settings?.required and !@content[field.slug]?
        @invalidate field.slug, 'required'
      else if @content[field.slug] is ''
        delete @content[field.slug]

    next()

entrySchema.path('publishDate').set (val='') ->
  parsed = chrono.parse(val)
  if parsed?[0]?.startDate
    parsed[0].startDate
  else
    Date.now()

entrySchema.path('description').validate (val) ->
  val?.length < 140
, 'Descriptions must be less than 140 characters.'

entrySchema.statics.findByParams = (params, callback) ->

  settings = _.defaults params,
    bucket: null
    until: 'Now'
    since: null
    limit: 10
    skip: 0
    status: 'live'
    sort: '-publishDate'
    find: ''
    slug: null
    search: null
    query: null

  searchQuery = {}

  async.parallel [
    (callback) ->
      if settings.bucket?
        filteredBuckets = settings.bucket.split '|'
        searchQuery.bucket = $in: []

        mongoose.model('Bucket').find {slug: $in: filteredBuckets}, (err, buckets) =>
          filteredBucketIDs = _.pluck _.filter(buckets, (bkt) -> bkt.slug in filteredBuckets), '_id'
          searchQuery.bucket = $in: filteredBucketIDs
          callback null
      else
        callback null
  ], =>
    if settings.slug
      searchQuery.slug = settings.slug

    if settings.where
      searchQuery.$where = settings.where

    if settings.status?.length > 0
      searchQuery.status = settings.status

    if settings.search?
      # Some default manipulation to make the search fuzzy
      # and case insensitive by default
      return @search query:
        fuzzy:
          _all:
            value: "#{settings.search.toLowerCase()}*"
            fuzziness: 5
            prefix_length: 2
      , (err, elasticEntries) ->
        throw err if err
        callback null, elasticEntries.hits

    if settings.query?
      return @search query:
        simple_query_string:
          query: settings.query
      , (err, elasticEntries) ->
        throw err if err
        callback null, elasticEntries.hits

    if settings.since or settings.until
      searchQuery.publishDate = {}
      searchQuery.publishDate.$gt = new Date(chrono.parseDate settings.since) if settings.since
      searchQuery.publishDate.$lte = new Date(chrono.parseDate settings.until) if settings.until

    @find searchQuery
      .populate 'bucket'
      .populate
        path: 'author'
        select: '-passwordDigest -resetPasswordToken -resetPasswordExpires'
      .sort settings.sort
      .limit settings.limit
      .skip settings.skip
      .exec (err, entries) ->
        throw err if err

        callback null, entries

entrySchema.set 'toJSON', virtuals: true

# Add Elasticsearch via mongoosastic
elasticConnection = url.parse config.elasticsearch.url
entrySchema.plugin mongoosastic,
  index: config.elasticsearch.index
  host: elasticConnection.hostname
  auth: elasticConnection.auth
  port: elasticConnection.port
  hydrate: yes
  hydrateOptions:
    populate: 'bucket author'

module.exports = db.model 'Entry', entrySchema
