express = require 'express'
cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'
session = require 'cookie-session'
colors = require 'colors'

passport = require './lib/auth'
util = require './lib/util'
config = require './config'

module.exports = app = express()

app.set 'views', 'public/'
app.set 'view engine', 'hbs'

# Handle cookies and sessions and stuff
app.use cookieParser config.buckets.salt
app.use bodyParser.json()
app.use bodyParser.urlencoded extended: true
app.use session secret: config.buckets.salt, name: 'buckets'

app.use passport.initialize()
app.use passport.session()

# Load Routes for the API, admin, and frontend
try
  for api in util.loadClasses "#{__dirname}/routes/api/"
    app.use "/#{config.buckets.apiSegment}", api if api.init
catch e
  console.log e
  throw 'Missing API Class'.red

app.use "/#{config.buckets.adminSegment}", require('./routes/admin')

app.use require './routes/frontend'

app.listen config.buckets.port

console.log ("\nBuckets is running at " + "http://localhost:#{config.buckets.port}/".underline.bold).yellow
