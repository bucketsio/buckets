url      = require 'url'
redis    = require 'redis'
config   = require './config'

redisURL = url.parse config.redisURL
redisDb  = redis.createClient(redisURL.port, redisURL.hostname)

if redisURL.auth
  redisDb.auth redisURL.auth.split(':')[1]

module.exports = redisDb
