Bucket = require '../server/models/bucket'
Entry = require '../server/models/entry'

module.exports =
  requiresDowntime: no # true or false

  up: (done) ->
    Entry.update {content: null}, {content: {}}, {multi: yes}, (e, entries) ->
      throw e if e

      stream = Entry.synchronize()
      count = 0

      stream.on 'data', (err, doc) -> count++
      stream.on 'close', ->
        console.log('Indexed ' + count + ' entries into ElasticSearch')
        done()

      stream.on 'error', (err) -> console.log err

  down: (done) ->
    done()
