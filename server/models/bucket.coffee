inflection = require 'inflection'
mongoose = require 'mongoose'
uniqueValidator = require 'mongoose-unique-validator'

Route = require '../models/route'
db = require '../lib/database'

bucketSchema = new mongoose.Schema
  name:
    type: String
    unique: yes
    required: yes
  slug:
    type: String
    unique: yes
    required: yes
  titleLabel:
    type: String
    default: 'Title'
  singular:
    type: String
    required: yes
  icon:
    type: String
    enum: ['edit', 'photos', 'calendar', 'movie', 'music-note', 'map-pin', 'quote', 'artboard', 'contacts-1']
    default: 'edit'
    required: yes
  color:
    type: String
    enum: ['teal', 'purple', 'red', 'yellow', 'blue', 'orange', 'green']
    default: 'teal'
    required: yes
  publishToSite:
    type: Boolean
    default: no
  urlPattern: String
  route:
    type: mongoose.Schema.Types.ObjectId
    ref: 'Route'
  fields: [
    name:
      type: String
      unique: no
      required: yes
    slug:
      type: String
      unique: yes
      required: yes
    required: Boolean
    instructions: String
    fieldType:
      type: String
      required: yes
    settings: mongoose.Schema.Types.Mixed
    dateCreated:
      type: Date
      default: new Date
  ]
,
  autoIndex: no

bucketSchema.set 'toJSON', virtuals: true

bucketSchema.pre 'validate', (next) ->
  # Auto add singular if not provided
  @singular ?= inflection.singularize @name
  next()

# Make sure it contains :slug
bucketSchema.path('urlPattern').validate (value) ->
  if @publishToSite
    /\/?:slug[\.\/]?/g.test value
  else
    true
, 'A :slug param is required.'

bucketSchema.plugin uniqueValidator, message: '“{VALUE}” is already taken.'

bucketSchema.post 'remove', ->
  @model('Entry').remove({bucket: @_id}).exec()

bucketSchema.methods.getMembers = (callback) ->
  @model('User').find
    roles:
      $elemMatch:
        resourceId: @_id
        resourceType: 'Bucket'
  , callback

module.exports = db.model 'Bucket', bucketSchema
