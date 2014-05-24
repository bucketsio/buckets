express = require 'express'
cookieParser = require 'cookie-parser'
bodyParser = require 'body-parser'
expressSession = require 'express-session'

passport = require './lib/auth'
util = require './lib/util'
config = require './config'

module.exports = app = express()

app.set 'views', 'public/'
app.set 'view engine', 'hbs'

# Handle cookies and sessions and stuff
app.use cookieParser config.buckets.salt
app.use bodyParser()
app.use expressSession secret: config.buckets.salt

# Passport deals with any possible auth
app.use passport.initialize()
app.use passport.session()

# Load Routes for the API, admin, and frontend
app.use "/#{config.buckets.apiSegment}", api for api in util.loadClasses "#{__dirname}/api/"
app.use "/#{config.buckets.adminSegment}", require('./routes/admin')
app.use require('./routes/frontend')

app.listen config.buckets.port

console.log "Buckets is running at http://localhost:#{config.buckets.port}/"