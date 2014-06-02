Field = require 'models/field'
Collection = require 'lib/collection'

module.exports = class Fields extends Collection
  url: '/api/fields/'
  model: Field
