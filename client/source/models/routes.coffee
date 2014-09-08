Collection = require 'lib/collection'
Route = require 'models/route'

module.exports = class Routes extends Collection
  url: '/api/routes/'
  model: Route
  comparator: 'sort'
