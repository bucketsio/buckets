Collection = require 'lib/collection'
Bucket = require 'models/bucket'

module.exports = class Buckets extends Collection
  url: '/api/buckets'
  model: Bucket
  comparator: 'name'
