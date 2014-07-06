mongoose = require 'mongoose'
db = require '../lib/database'

fieldSchema = new mongoose.Schema
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
  fieldType: String
  settings: mongoose.Schema.Types.Mixed
  dateCreated:
    type: Date
    default: new Date
  config: {}
,
  autoIndex: no

fieldSchema.path('slug').validate (val) ->
  val not in ['title', 'description', 'slug', 'status', 'lastModified', 'publishDate', 'createdAt', 'author', 'bucket', 'keywords', 'content']
, 'Sorry, that’s a reserved field slug.'

module.exports = db.model 'Field', fieldSchema
