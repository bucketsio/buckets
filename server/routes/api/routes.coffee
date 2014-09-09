express = require 'express'

Route = require '../../models/route'

module.exports = app = express()

###
@api {get} /routes Get Routes
@apiVersion 0.0.4
@apiGroup Routes
@apiGroupDescription Routes can be saved by Users and are a way to match frontend URL patterns to templates.
@apiName GetRoutes

@apiParam {String} template=index Currently, this is file-based, though it may be tracked in the database soon.
@apiParam {String} urlPattern='/' An [Express-style URL pattern](https://github.com/component/path-to-regexp) (which captures named parameters).

@apiPermission administrator

@apiSuccessExample Success-Response:
HTTP/1.1 200 OK
[
  {
    "urlPatternRegex":{},
    "urlPattern":"/",
    "template":"index",
    "createdDate":"2014-08-16T05:26:40.367Z",
    "keys":[],
    "id":"53eeeb90605b111826ddd57c"
  },
  {
    "urlPatternRegex":{},
    "urlPattern":"/:slug",
    "template":"index",
    "createdDate":"2014-08-16T05:26:40.369Z",
    "keys":[
      {
        "name":"slug",
        "delimiter":"/",
        "optional":false,
        "repeat":false
      }
    ],
    "id":"53eeeb90605b111826ddd57d"
  }
]
###

app.route('/routes')
  .get (req, res) ->
    return res.status(401).end() unless req.user?.hasRole ['administrator']

    Route.find {}, null, sort: 'sort', (err, routes) ->
      if err
        res.send err, 400
      else if routes
        res.send routes

  .post (req, res) ->
    ###
      @api {post} /routes Create a Route
      @apiVersion 0.0.4
      @apiGroup Routes
      @apiName GetRoutes

      @apiPermission administrator
    ###
    return res.status(401).end() unless req.user?.hasRole ['administrator']

    newRoute = new Route req.body

    newRoute.save (err, route) ->
      if err
        res.status(400).send err
      else
        res.status(201).send route

###
@api {post} /routes/:id Remove a Route
@apiVersion 0.0.4
@apiGroup Routes
@apiName GetRoutes

@apiPermission administrator

@apiSuccessExample Success-Response:
HTTP/1.1 204 No Content
###

###
@api {post} /routes Update a Route
@apiVersion 0.0.4
@apiGroup Routes
@apiName PutRoute

@apiPermission administrator
###

app.route('/routes/:routeID')
  .delete (req, res) ->
    return res.status(401).end() unless req.user?.hasRole ['administrator']

    Route.remove _id: req.params.routeID, (err) ->
      if err
        res.status(400).send err
      else
        res.status(204).end()

  .put (req, res) ->
    return res.status(401).end() unless req.user?.hasRole ['administrator']

    Route.find _id: req.params.routeID, null, limit: 1, (err, routes) ->
      return res.status(404).end() unless route = routes?[0]

      route.set req.body
      route.save (err, route) ->
        if err
          res.status(400).send err
        else
          res.status(200).send route
