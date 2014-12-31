mongoose = require 'mongoose'
db = require '../lib/database'
logger = require '../lib/logger'

# Conforms, at least somewhat, to the activity stream spec outlined at
# http://activitystrea.ms/specs/json/1.0
activitySchema = new mongoose.Schema
  publishDate:
    type: Date
    default: Date.now
  actor:
    type: mongoose.Schema.Types.ObjectId
    ref: 'User'
    required: true
  action:
    type: String
    enum: ['created', 'updated', 'deleted']
    required: true
  resource:
    id:
      type: mongoose.Schema.Types.ObjectId
      required: true
    type:
      type: String
      required: true
      enum: ['entry', 'bucket', 'user']
    name:
      type: String
      required: true
    # for users
    email:
      type: String
    bucket:
      id:
        type: mongoose.Schema.Types.ObjectId
      slug:
        type: String
      singular:
        type: String
,
  toJSON:
    virtuals: yes
    transform: (doc, ret, options) ->
      delete ret._id
      delete ret.__v
      ret

activitySchema.virtual 'resource.kind'
  .get ->
    if @resource.type is 'entry'
      @resource.bucket.singular.toLowerCase()
    else
      @resource.type

activitySchema.virtual 'resource.path'
  .get ->
    switch @resource.type
      when 'entry' then "/buckets/#{@resource.bucket.slug}/#{@resource.id}"
      when 'bucket' then "/buckets/#{@resource.bucket.slug}"
      when 'user' then "/users/#{@resource.email}"

activitySchema.statics.createForResource = (resource, action, actor, callback) ->
  @create { resource, action, actor }, (err, activity) ->
    if err
      logger.error 'Error creating Activity', activity, err
    else
      callback(action) if callback

activitySchema.statics.unlinkActivities = (resource) ->
  @update { 'resource.id': resource._id }, { $set: { 'resource.id': null }}, { multi: true }, (err) ->
    logger.error 'Error unlinking Activities', resource, err if err

module.exports = db.model 'Activity', activitySchema
