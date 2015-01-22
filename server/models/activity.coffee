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
    kind:
      type: String
    name:
      type: String
      required: true
    entry:
      type: mongoose.Schema.Types.ObjectId
      ref: 'Entry'
    bucket:
      type: mongoose.Schema.Types.ObjectId
      ref: 'Bucket'
    user:
      type: mongoose.Schema.Types.ObjectId
      ref: 'User'
,
  toJSON:
    virtuals: yes
    transform: (doc, ret, options) ->
      delete ret._id
      delete ret.__v
      ret

activitySchema.virtual 'resource.path'
  .get ->
    if @resource.entry or @resource.bucket or @resource.user
      switch @resource.kind
        when 'bucket' then "/buckets/#{@resource.bucket.slug}"
        when 'user' then "/users/#{@resource.user.email}"
        else "/buckets/#{@resource.bucket.slug}/#{@resource.entry.id}"

activitySchema.statics.createForResource = (resource, action, actor, callback) ->
  @create { resource, action, actor }, (err, activity) ->
    if err
      logger.error 'Error creating Activity', activity, err
    else
      callback(action) if callback

activitySchema.statics.unlinkActivities = (conditions) ->
  @update conditions,
    {
      $set:
        'resource.entry': null
        'resource.bucket': null
        'resource.user': null
    },
    { multi: true },
    (err) ->
      logger.error 'Error unlinking Activities', resource, err if err

module.exports = db.model 'Activity', activitySchema
