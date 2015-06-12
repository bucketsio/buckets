Collection = require 'lib/collection'
Activity = require 'models/activity'

module.exports = class Activities extends Collection
  url: '/api/activities'
  model: Activity