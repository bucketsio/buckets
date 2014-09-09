Route = require '../../../server/models/route'
reset = require '../../reset'

{expect} = require 'chai'

describe 'Model#Route', ->
  bucket = null
  user = null

  before reset.db
  afterEach reset.db

  describe 'Validation', ->
    it 'requires a template string', (done) ->
      route = new Route
      route.save (e, route) ->
        expect(e).to.match /ValidationError/
        done()

  describe 'Creation', ->
    it 'follows the schema', (done) ->
      route = new Route
        template: 'index'
      route.save (e, route) ->
        expect(route.toJSON()).to.have.keys ['urlPattern', 'urlPatternRegex', 'keys', 'template', 'id', 'sort', 'isCanonical']
        done()

    it 'automatically creates a urlPatternRegex', (done) ->
      route = new Route
        template: 'index'
        urlPattern: '/articles/:id'
      route.save (e, route) ->
        expect(route.urlPatternRegex).to.be.a 'RegExp'
        expect(route.keys[0].name).to.equal 'id'
        done()

    it 'can determine a canonical URL', (done) ->
      route = new Route
        template: 'index'
        urlPattern: '/:slug'
      route.save (e, route) ->
        expect(route.isCanonical).to.be.true
        done()

    it 'can determine a non-canonical URL', (done) ->
      route = new Route
        template: 'index'
        urlPattern: '/:thing'
      route.save (e, route) ->
        expect(route.isCanonical).to.be.false
        done()
