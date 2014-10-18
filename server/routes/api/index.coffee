express = require 'express'

module.exports = app = express()

app.use require './buckets'
app.use require './entries'
app.use require './install'
app.use require './routes'
app.use require './buildfiles'
app.use require './users'
app.use require './management'
app.use require './dropbox'
app.use require './builds'
