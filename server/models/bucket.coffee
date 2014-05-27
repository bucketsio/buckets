lingo = require 'lingo'
mongoose = require 'mongoose'

Route = require '../models/route'
db = require '../lib/database'

bucketSchema = new mongoose.Schema
  name:
    type: String
    index:
      unique: yes
    required: yes
  slug:
    type: String
    unique: yes
  titleLabel: 
    type: String
    default: 'Title'
  icon:
    type: String
    default: 'bucket'
  color:
    type: String
  publishToSite:
    type: Boolean
    default: no
  urlPattern: String
  route:
    type: mongoose.Schema.Types.ObjectId
    ref: 'Route'
  fields: [
    type: mongoose.Schema.Types.ObjectId
    ref: 'Field'
  ]
,
  autoIndex: no

bucketSchema.virtual('singular').get ->
  lingo.en.singularize @name

bucketSchema.virtual('path').get ->
  lingo.camelcase @name

bucketSchema.set 'toJSON', virtuals: true

# Make sure it contains :slug
bucketSchema.path('urlPattern').validate (value) ->
  if @publishToSite
    /\/?:slug[\.\/]?/g.test value 
  else
    true
  
, 'requiresSlug'


module.exports = db.model 'Bucket', bucketSchema