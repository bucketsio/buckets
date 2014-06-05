express = require 'express'

Bucket = require '../../models/bucket'
FieldTypes = require '../../lib/fieldtypes'

module.exports = app = express()

app.route('/fieldtypes')
  .get (req, res) ->
    res.send FieldTypes.load()
