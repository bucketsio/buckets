mongoose = require 'mongoose'
db = require '../lib/database'
pathRegexp = require('path-to-regexp')

require('mongoose-regexp')(mongoose)

routeSchema = new mongoose.Schema
  urlPattern:
    type: String
    required: yes
    index: yes
    trim: yes
  urlPatternRegex:
    type: RegExp
    required: yes
  template:
    type: String
    required: yes
  sort: Number
  keys: []
  createdDate:
    type: Date
    default: Date.now
  isBucketRoute:
    type: Boolean
    default: no
,
  autoIndex: no

routeSchema.path('urlPattern').validate (value) ->
  !/[^a-zA-Z0-9-_\/:]|(^\/\/)/g.test value
, 'characters'

routeSchema.pre 'validate', (next) ->
  # Force the initial slash for consistency
  # (trailing slash is up to user)
  # Also truncate any multiple slashes to one...
  @urlPattern = "/#{@urlPattern}".replace(/\/\/+/g, '/').replace('?', '')

  # Generate the Express path regex
  @keys = []
  @urlPatternRegex = pathRegexp @urlPattern, @keys, yes, no

  next()

routeSchema.set 'toJSON', virtuals: true

module.exports = db.model 'Route', routeSchema
