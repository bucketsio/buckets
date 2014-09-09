inflection = require 'inflection'
mongoose = require 'mongoose'
uniqueValidator = require 'mongoose-unique-validator'

Route = require '../models/route'
db = require '../lib/database'

fieldSchema = new mongoose.Schema
  name:
    type: String
    unique: no
    required: yes
  slug:
    type: String
    index: yes
    required: yes
  required: Boolean
  instructions: String
  fieldType:
    type: String
    required: yes
  settings: {}

fieldSchema
  .path 'slug'
  .validate (val) ->
    val not in [
      'title'
      'description'
      'slug'
      'status'
      'lastModified'
      'publishDate'
      'createdAt'
      'author'
      'bucket'
      'keywords'
      'content'
    ]
  , 'Sorry, that’s a reserved field slug.'

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
  titlePlaceholder:
    type: String
  singular:
    type: String
    required: yes
  icon:
    type: String
    enum: [
      'edit'
      'camera-front'
      'calendar'
      'video-camera'
      'headphone'
      'map'
      'quote'
      'shopping-bag'
      'cocktail'
      'globe'
      'call'
      'goal'
      'megaphone'
      'star'
      'chat-bubble'
      'bookmark'
      'toolbox'
      'person'
    ]
    default: 'edit'
    required: yes
  color:
    type: String
    enum: ['teal', 'purple', 'red', 'yellow', 'blue', 'orange', 'green']
    default: 'teal'
    required: yes
  fields: [fieldSchema]
,
  toJSON:
    virtuals: yes
    transform: (doc, ret, options) ->
      delete ret._id
      delete ret.__v
      ret

bucketSchema.pre 'validate', (next) ->
  # Auto add singular if not provided
  @singular ?= inflection.singularize @name if @name
  next()

bucketSchema.plugin uniqueValidator, message: '“{VALUE}” is already taken.'

bucketSchema.post 'remove', ->
  @model('Entry').remove(bucket: @_id).exec()

bucketSchema.methods.getMembers = (callback) ->
  @model('User').find
    roles:
      $elemMatch:
        resourceId: @_id
  , callback

module.exports = db.model 'Bucket', bucketSchema
