lingo = require 'lingo'
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
    enum: ['photos', 'calendar', 'movie', 'music-note', 'map-pin', 'quote', 'edit']
    default: 'edit'
    required: yes
  color:
    type: String
    enum: ['teal', 'purple', 'red', 'yellow', 'blue', 'orange']
    required: yes
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

bucketSchema.set 'toJSON', virtuals: true

bucketSchema.pre 'validate', (next) ->
  @singular ?= lingo.en.singularize @name
  next()

# Make sure it contains :slug
bucketSchema.path('urlPattern').validate (value) ->
  if @publishToSite
    /\/?:slug[\.\/]?/g.test value
  else
    true

, 'requiresSlug'

bucketSchema.plugin uniqueValidator, message: '“{VALUE}” is already taken.'

module.exports = db.model 'Bucket', bucketSchema
