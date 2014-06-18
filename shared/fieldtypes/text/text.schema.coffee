module.exports = class LocationFieldType
  schema:
    value: String
    latitude: String
    longitude: String

  # Or...

  schema: ->
    mongoose = require 'mongoose'

  getField: (fieldData) ->
    # Returns HTML for the field’s input on an Entry

  editField: (fieldSettings) ->
    # Returns HTML for configuring the field on a Bucket

  helpers:
    renderMap: ->
      # Renders a map UI with the location
