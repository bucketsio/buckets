mongoose = require 'mongoose'
_ = require 'underscore'
chrono = require 'chrono-node'
async = require 'async'
getSlug = require 'speakingurl'

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

entrySchema = new mongoose.Schema
  title:
    type: String
    required: yes
  description: String
  slug:
    type: String
  status:
    type: String
    enum: ['draft', 'live', 'pending', 'rejected']
    required: yes
    default: 'live'
  lastModified:
    type: Date
  publishDate:
    type: Date
    default: Date.now
    index: yes
  createdDate:
    type: Date
    default: Date.now
  author:
    type: mongoose.Schema.Types.ObjectId
    ref: 'User'
    required: yes
  bucket:
    type: mongoose.Schema.Types.ObjectId
    ref: 'Bucket'
    required: yes
  keywords:
    type: [
      type: String
      trim: yes
    ]
    default: []
  content: {}
,
  toJSON:
    virtuals: yes
    transform: (doc, ret, options) ->
      delete ret._id
      delete ret.__v
      ret

entrySchema.pre 'save', (next) ->
  @lastModified = Date.now()
  next()

entrySchema.pre 'validate', (next) ->
  @slug ?= getSlug @title

  @model('Bucket').findOne _id: @bucket, (err, bkt) =>

    @invalidate 'bucket', 'Must belong to a bucket' unless bkt

    for field in bkt?.fields or []
      if field.settings?.required and !@content[field.slug]
        @invalidate field.slug, 'required'

    next()

entrySchema.path('publishDate').set (val='') ->
  parsed = chrono.parse(val)?[0]?.startDate
  parsed || Date.now()


entrySchema.path('description').validate (val) ->
  val?.length < 140
, 'Descriptions must be less than 140 characters.'

entrySchema.path 'keywords'
  .set (val) ->
    return unless _.isString val
    _.compact _.map val.split(','), (val) -> val.trim()

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

    if settings.since or settings.until
      searchQuery.publishDate = {}
      searchQuery.publishDate.$gt = new Date(chrono.parseDate settings.since) if settings.since
      searchQuery.publishDate.$lte = new Date(chrono.parseDate settings.until) if settings.until

    @find searchQuery
      .populate
        path: 'bucket'
        select: '-fields'
        limit: 1
      .populate
        path: 'author'
        select: '-roles -last_active -date_created -activated'
        limit: 1
      .select('-createdDate')
      .sort settings.sort
      .limit settings.limit
      .skip settings.skip
      .exec (err, entries) ->
        entries = entries.map (entry) -> entry.toJSON()

        if err
          callback err
        else
          callback null, entries

module.exports = db.model 'Entry', entrySchema
