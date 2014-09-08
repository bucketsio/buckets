_ = require 'underscore'
mongoose = require 'mongoose'
db = require '../lib/database'
pathRegexp = require 'path-to-regexp'

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
  sort:
    type: Number
    default: 0
    index: yes
  keys: []
,
  toJSON:
    virtuals: yes
    transform: (doc, ret) ->
      delete ret._id
      delete ret.__v
      ret

routeSchema.pre 'validate', (next) ->
  @urlPattern ?= ''

  # Force the initial slash for consistency
  # (trailing slash is up to user)
  # Also truncate any multiple slashes to one...
  @urlPattern = "/#{@urlPattern}".replace(/\/\/+/g, '/')

  # Generate the Express path regex
  # and saves the keys to an array
  @keys = []
  @urlPatternRegex = pathRegexp @urlPattern, @keys, yes, no
  @invalidate 'urlPattern', 'That is not a valid URL pattern.' unless _.isRegExp @urlPatternRegex
  next()

routeSchema.virtual('isCanonical').get ->
  return no unless @keys?.length
  for key in @keys
    return no unless key.name in ['slug', 'year', 'month', 'day', 'bucket', 'slug']
  yes

module.exports = db.model 'Route', routeSchema
