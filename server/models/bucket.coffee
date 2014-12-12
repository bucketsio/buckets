inflection = require 'inflection'
mongoose = require 'mongoose'
uniqueValidator = require 'mongoose-unique-validator'
winston = require 'winston'

Route = require '../models/route'
db = require '../lib/database'
{Sortable} = require '../lib/mongoose-plugins'

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
,
  toJSON:
    getters: true

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

fieldSchema.virtual 'slug.old'
  .get -> @_slug
  .set (slug) -> @_slug = slug

fieldSchema.post 'init', ->
  @set 'slug.old', @get 'slug'

fieldSchema.post 'save', ->
  if @get('slug.old') isnt @get('slug')
    oldPath = "content.#{@get 'slug.old'}"
    newPath = "content.#{@get 'slug'}"
    q = {}
    q[oldPath] = $exists: yes
    u = {$rename: {}}
    u.$rename[oldPath] = newPath

    # TODO will probably have to change due to #168
    mongoose.model('Entry').update q, u, {}, (err) ->
      winston.error err if err?

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
    enum: ['teal', 'purple', 'red', 'yellow', 'blue', 'orange', 'green', 'gray']
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
bucketSchema.plugin Sortable
bucketSchema.plugin Sortable, embedded: 'fields'

bucketSchema.post 'remove', ->
  @model('Entry').remove(bucket: @_id).exec()

bucketSchema.methods.getMembers = (callback) ->
  @model('User').find
    roles:
      $elemMatch:
        resourceId: @_id
  , callback

module.exports = db.model 'Bucket', bucketSchema
