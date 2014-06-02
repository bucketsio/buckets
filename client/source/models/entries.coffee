Collection = require 'lib/collection'
Entry = require 'models/entry'

module.exports = class Entries extends Collection
  url: '/api/entries/'
  model: Entry

  fetchByBucket: (bucketId) ->
    @url += "?#{$.param(bucketId: bucketId)}"
    @fetch()
