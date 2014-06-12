mongoose = require 'mongoose'
db = require '../lib/database'

Route = require('./route')

# We should be mindful of potential exploits in user-provided input,
# but MongoDB appears to be safe for the basic use case.
# http://docs.mongodb.org/manual/faq/developers/#how-does-mongodb-address-sql-or-query-injection

Template = new mongoose.Schema
  filename:
    type: String
    required: true
  contents: String
  date_created:
    type: Date
    default: Date.now
  last_modified:
    type: Date
    default: Date.now
  primary:
    type: Boolean
    default: false
  directory: String

makePrimary = (bool, next) ->
  if bool
    Template.update { primary: true }, { primary: false }, { multi: true }, (err) ->
      next(err)
  else
    next()

Template.pre 'save', (next) ->
  @last_modified = Date.now()
  makePrimary(@primary, next)

Template.statics.renameRoutes = (oldName, newName, callback) ->
  Route.update({ template: oldName }, { template: newName }, callback)

module.exports = db.model('Template', Template)
