Collection = require 'lib/collection'
Template = require 'models/template'

module.exports = class Templates extends Collection
  url: '/api/templates/'
  model: Template
  comparator: 'filename'
