mongoose = require 'mongoose'
db = require '../lib/database'

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
  autoIndex: no

activitySchema.set 'toJSON', virtuals: true

activitySchema.virtual 'resource.path'
  .get ->
    if @resource.entry or @resource.bucket or @resource.user
      switch @resource.kind
        when 'bucket' then '/buckets/' + @resource.bucket.slug
        when 'user' then '/users/' + @resource.user.email
        else '/buckets/' + @resource.bucket.slug + '/' + @resource.entry.id

activitySchema.statics.createForResource = (resource, action, actor, callback) ->
  @model('Activity').create { resource, action, actor }, (err, activity) ->
    if err
      console.log 'Error creating Activity', activity, err
    else
      callback(action) if callback

activitySchema.statics.unlinkActivities = (conditions) ->
  @model('Activity').update conditions,
    {
      $set:
        'resource.entry': null
        'resource.bucket': null
        'resource.user': null
    },
    { multi: true },
    (err) ->
      console.log 'Error unlinking Activities', resource, err if err

module.exports = db.model 'Activity', activitySchema
