Model = require 'lib/model'

module.exports = class Activity extends Model
  urlRoot: '/api/activities'

  hello: ->
    'test'