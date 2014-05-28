express = require 'express'

Route = require '../../models/route'

module.exports = app = express()

app.route('/routes')
  .get (req, res) ->
    Route.find().sort(urlPattern: 1).exec (err, routes) ->
      if err
        res.send err, 400
      else if routes
        res.send routes

  .post (req, res) ->
    console.log 'hrm'
    newRoute = new Route req.body

    newRoute.save (err) ->
      if err
        res.send 400, err
      else
        res.send 201, newRoute

app.route('/routes/:routeID')
  .delete (req, res) ->
    Route.remove _id: req.params.routeID, (err) ->
      if err
        res.send 400, err
      else
        res.send 200, {}

  .put (req, res) ->
    Route.findById(req.params.routeID).exec (err, route) ->
      if err or not route
        res.send 400
      else
        route.set req.body
        
        route.save (err) ->
          if err
            res.send 500, err
          else
            res.send route