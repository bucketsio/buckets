Controller = require 'lib/controller'
DashboardView = require 'views/buckets/dashboard'
MissingPageView = require 'views/missing'

module.exports = class BucketsController extends Controller
  
  dashboard: ->
    console.log @view = new DashboardView

  missing: ->
    console.log 'Page missing!', arguments