Model = require 'lib/model'

module.exports = class Build extends Model
  urlRoot: '/api/builds/'
  defaults:
    env: 'staging'

  checkDropbox: ->
    @api '/api/builds/dropbox/check'
  disconnectDropbox: ->
