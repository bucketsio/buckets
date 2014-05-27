mongoose = require 'mongoose'
db = require '../lib/database'

date = require 'date.js'

Schema = mongoose.Schema

entrySchema = new Schema
  title:
    type: String
    required: yes
  description: String
  slug:
    type: String
  status:
    type: String
    enum: ['hidden', 'draft', 'live']
    required: yes
    default: 'draft'
  lastModified:
    type: Date
  publishDate:
    type: Date
    default: Date.now
  createdDate:
    type: Date
    default: Date.now
  template:
    type: Schema.Types.ObjectId
    ref: 'Template'
  author:
    type: Schema.Types.ObjectId
    ref: 'Person'
  bucket:
    type: Schema.Types.ObjectId
    ref: 'Bucket'
  keywords: [
    type: String
    trim: yes
  ]
,
  strict: no

pageSchema.pre 'validate', (next) ->
  if typeof @keywords is 'string'
    @keywords = @keywords.split ','
  next()

pageSchema.pre 'save', (next) ->
  @lastModified = Date.now()
  next()

pageSchema.path('publishDate').set (val) ->
  parsed = date(val)
  console.log parsed is Date.now()
  parsed

# pageSchema.virtual('depth').get ->
#   @path.split('/').length - 1

pageSchema.path('description').validate (val) ->
  val?.length < 140
, 'Descriptions must be less than 140 characters.'

pageSchema.set 'toJSON', virtuals: true

module.exports = db.model 'Page', pageSchema
