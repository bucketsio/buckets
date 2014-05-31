_ = require 'underscore'
Collection = require 'lib/collection'
Member = require 'models/member'

module.exports = class Members extends Collection
  initialize: (options) ->
    @bucketId = options.bucketId

  url: ->
    "/api/buckets/#{@bucketId}/members"

  model: Member
