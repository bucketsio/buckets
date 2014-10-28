Model = require 'lib/model'

module.exports = class Template extends Model
  urlRoot: ->
    "/api/buildfiles/#{@get('build_env')}/"
  idAttribute: 'filename'
  defaults:
    filename: ''
    contents: ''
    build_env: 'staging'
