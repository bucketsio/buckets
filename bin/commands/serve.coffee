module.exports = ->
  buckets = require '../../'
  server = buckets
    buildsPath: "./builds/"
  server.on 'bucketsError', ->
    process.exit()
