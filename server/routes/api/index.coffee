express  = require 'express'

Limiter  = require 'ratelimiter'
config   = require '../../config'
redisDb  = require '../../redis'



# use router instead of just express app.
module.exports = app = express.Router()

app.use (req, res, next) ->
  if req.user?
    limit = new Limiter({ id: req.user._id, db: redisDb, max: config.apiHourlyLimit })
    limit.get (err, limit) ->
      if err?
        return next err

      res.set 'X-RateLimit-Limit', limit.total
      res.set 'X-RateLimit-Remaining', limit.remaining
      res.set 'X-RateLimit-Reset', limit.reset

      # all good
      if limit.remaining
        return next()

      # not good
      delta = (limit.reset * 1000) - Date.now() | 0
      after = limit.reset - (Date.now() / 1000) | 0
      res.set 'Retry-After', after
      res.status(429).send('Rate limit exceeded, retry in ' + delta)
  else
    next()

app.use require './buckets'
app.use require './entries'
app.use require './install'
app.use require './routes'
app.use require './templates'
app.use require './users'
app.use require './management'
