Model = require 'lib/model'

Bucket = require 'models/bucket'
FieldData = require 'models/field_data'

module.exports = class Entry extends Model
  defaults:
    title: ''
    keywords: ''
    description: ''
    status: 'draft'
    slug: ''
    content: {}
  urlRoot: '/api/entries'

  parse: (response) ->
    for key, value of response
      continue unless key is 'content'
      content = {}
      for slug, prop of value
        content[slug] = new FieldData prop
      response[key] = content
    response

