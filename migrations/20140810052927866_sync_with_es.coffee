Bucket = require './server/models/bucket'
Entry = require './server/models/entry'

http = require 'http'
config = require './server/config'

module.exports =
  requiresDowntime: no # true or false

  up: (done) ->
    Entry.update {content: null}, {content: {}}, {multi: yes}, (e, entries) ->
      throw e if e

      Entry.createMapping (err) ->
        throw e if e
        stream = Entry.synchronize()
        count = 0

        stream.on 'data', (e, doc) -> count++
        stream.on 'close', ->
          console.log('Indexed ' + count + ' entries into ElasticSearch')
          done()

        stream.on 'error', (e) -> throw e

  down: (done) ->
    done()
