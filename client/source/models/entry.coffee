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
  urlRoot: '/api/entries'
