mongoose = require 'mongoose'
db = require '../lib/database'
pathRegexp = require('express/lib/utils').pathRegexp

routeSchema = new mongoose.Schema
  urlPattern:
    type: String
    required: yes
    index: yes
    trim: yes
  urlPatternRegex:
    type: String
    required: yes
  template:
    type: String
    required: yes
  sort: Number
  keys: {}
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
  # Nix the initial slash for consistency
  # (trailing slash is up to user)
  # Also truncate any multiple slashes to one...
  @urlPattern = @urlPattern.replace(/^\/+/, '').replace(/\/\/+/g, '/')

  # Generate the Express path regex
  @keys = []
  @urlPatternRegex = pathRegexp @urlPattern, @keys, yes, no

  next()


routeSchema.set 'toJSON', virtuals: true

module.exports = db.model 'Route', routeSchema