mongoose = require 'mongoose'

module.exports = locationSchema = new mongoose.Schema
  value: String
  latlng: [Number]
