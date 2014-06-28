Model = require 'lib/model'

module.exports = class Bucket extends Model
  urlRoot: '/api/buckets'
  defaults:
    fields: []
    color: 'teal'
    icon: 'edit'
