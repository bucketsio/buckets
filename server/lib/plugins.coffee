glob = require 'glob'
mongoose = require 'mongoose'
_ = require 'underscore'
db = require '../lib/database'

# cwd = "#{__dirname}/../../shared/fieldtypes/"

module.exports =
  load: ->
    fieldtypes = {}
    dirs = glob.sync 'node_modules/buckets-*/'

    _.map dirs, (dir) ->
      dir.match(/^node_modules\/buckets\-(.*)\//)?[1]

    # TODO: Attach server-side schema here

    # for dir in dirs
    #   Klass = dbModel = null
    #   ftLabel = dir.replace('/', '')

    #   try
    #     # Can be JS, CS, or JSON
    #     Klass = require "#{cwd + dir + ftLabel}.schema"
    #   catch e
    #     Klass = {value: String}

    #   continue unless Klass

    #   if Klass instanceof mongoose.Schema
    #     dbModel = db.model ftLabel, Klass

    #   else if _.isObject Klass
    #     try
    #       schema = new mongoose.Schema Klass
    #       dbModel = db.model ftLabel, schema
    #     catch e
    #       continue

    #   fieldtypes[ftLabel] = dbModel if dbModel

    # fieldtypes
