Model = require 'lib/model'

Bucket = require 'models/bucket'

module.exports = class Entry extends Model
  defaults:
    title: ''
    keywords: ''
    description: ''
    status: 'draft'
    slug: ''
    content: {}
  idAttribute: '_id'
  urlRoot: '/api/entries'
