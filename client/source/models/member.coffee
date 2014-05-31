_ = require 'underscore'
Model = require 'lib/model'

module.exports = class Member extends Model
  urlRoot: ->
    "/api/buckets/#{@get('bucketId')}/members"
