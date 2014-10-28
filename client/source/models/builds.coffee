Collection = require 'lib/collection'
Build = require 'models/build'

module.exports = class Builds extends Collection
  url: '/api/builds'
  model: Build
  comparator: '-timestamp'
