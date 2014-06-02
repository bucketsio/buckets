mongoose = require 'mongoose'
db = require '../lib/database'

# We should be mindful of potential exploits in user-provided input,
# but MongoDB appears to be safe for the basic use case.
# http://docs.mongodb.org/manual/faq/developers/#how-does-mongodb-address-sql-or-query-injection

Template = new mongoose.Schema
  name:
    type: String
    required: true
  contents: String
  date_created:
    type: date
    default: Date.now
  last_modified:
    type: Date
    default: Date.now
  tags: [String]

module.exports = db.model('Template', Template)
