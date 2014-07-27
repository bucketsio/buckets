mongoose = require 'mongoose'
db = require '../lib/database'

# Conforms, at least somewhat, to the activity stream spec outlined at
# http://activitystrea.ms/specs/json/1.0
activitySchema = new mongoose.Schema
  published:
    type: Date
    default: Date.now
  actor:
    id:
      type: mongoose.Schema.Types.ObjectId
      ref: 'User'
      required: true
  verb:
    name:
      type: String
      enum: ['post', 'update']
      required: true
  object:
    objectType:
      type: String
      required: true
      enum: ['entry', 'bucket', 'user']
    id:
      type: mongoose.Schema.Types.ObjectId
      required: true
,
  autoIndex: no

activitySchema.set 'toJSON', virtuals: true

module.exports = db.model 'Activity', activitySchema
