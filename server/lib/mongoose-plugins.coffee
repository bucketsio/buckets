mongoose = require 'mongoose'
_ = require 'underscore'

module.exports.Sortable = (schema, options={}) ->
  if options.embedded
    parentSchema = schema
    schema = parentSchema.path(options.embedded).schema

  schema.isSortable = yes
  schema.add
    sort:
      type: Number
      default: 0
      index: yes

  if options.embedded
    parentSchema.pre 'save', (next) ->
      _.sortBy @[options.embedded], 'sort'
      next()
