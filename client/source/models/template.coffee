Model = require 'lib/model'

module.exports = class Template extends Model
  urlRoot: '/api/templates'
  idAttribute: 'filename'
  defaults:
    filename: ''
    contents: ''
