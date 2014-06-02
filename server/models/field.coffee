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
,
  autoIndex: no

module.exports = db.model 'Field', fieldSchema
