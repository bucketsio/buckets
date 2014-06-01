# Middleware to control the rest of the requests.
hbs = require 'hbs'
pathRegexp = require 'path-to-regexp'
express = require 'express'
_ = require 'underscore'

config = require '../config'
Route = require '../models/route'

module.exports = app = express()
tplPath = config.buckets?.templatePath

require('../lib/renderer')(hbs)

app.set 'views', tplPath

app.get '*', (req, res, next) ->

  # dynamic renderTime helper
  startTime = new Date
  hbs.registerHelper 'renderTime', ->
    endTime = new Date
    renderTimeMS = (endTime.getTime() - startTime.getTime()) + 'ms'
    "#{req.path} rendered in #{renderTimeMS}."

  templateData =
    adminSegment: config.buckets.adminSegment
    # Expose select items from the request object
    req:
      body: req.body
      path: req.path
      query: unless _.isEmpty(req.query) 
          req.query 
        else 
          false
      params: {} # We fill this manually later

  renderError = ->
    next() unless config.buckets.catchAll

    templateData.errorCode = 404
    templateData.errorText = 'Page missing'

    res.render 'index', templateData, (err, html) ->
      console.log 'err', err if err
      if err
        next()
      else
        res.send 404, html

  # We could use a $where here, but it's basically the same
  # since a basic $where scans all rows (plus this gives us more flexibility)
  Route.find().exec (err, routes) ->
    throw err if err

    for route in routes
      keys = []
      pathRE = pathRegexp route.urlPattern, keys, yes, no

      # Execute the regex on the path without an initial slash
      matches = pathRE.exec req.path.replace(/^\//, '')

      if matches
        # Add the URL wildcards
        templateData.req.params[key.name] = matches[i+1] for key, i in keys

        return res.render route.template, templateData, (err, html) ->
          if err
            renderError()
          else
            return res.send html
    
    return res.render 'index', templateData if req.path is '/'

    renderError()