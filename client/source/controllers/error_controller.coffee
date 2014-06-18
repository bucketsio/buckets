Controller = require 'lib/controller'

module.exports = class ErrorController extends Controller
  general: ->
    console.log 'there was a general error'
