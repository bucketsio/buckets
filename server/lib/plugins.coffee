glob = require 'glob'
mongoose = require 'mongoose'
_ = require 'underscore'
Handlebars = require 'hbsfy/runtime'

db = require '../lib/database'
config = require '../config'

cwd = config.buckets?.pluginsPath

module.exports =
  load: ->
    return [] unless cwd

    fieldtypes = {}
    dirs = glob.sync "#{cwd}buckets-*/", cwd: cwd

    _.map dirs, (dir) ->
      pluginSlug = dir.match(/\/buckets\-(.*)\//)?[1]

      try
        Plugin = require "../../#{dir}server"

      unless _.isFunction(Plugin)
        console.log "Could not find a server-side plugin for #{pluginSlug}".grey
        return slug: pluginSlug

      # Initiate it with a copy of Handlebars
      plugin = new Plugin
        Handlebars: Handlebars

      # Find the schema if there is one
      if plugin.schema instanceof mongoose.Schema
        dbModel = db.model pluginSlug, mongoose.schema
      else if _.isObject plugin.schema
        try
          schema = new mongoose.Schema plugin.schema
          dbModel = db.model pluginSlug, schema
        catch e
          console.log 'Error', e
          # continue

      #
      slug: pluginSlug
      server: plugin
      model: dbModel
