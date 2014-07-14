Swag = require 'swag'
_ = require 'underscore'

config = require '../config'
Entry = require '../models/entry'
Bucket = require '../models/bucket'
moment = require 'moment'

module.exports = (hbs) ->

  # Add Swag helpers
  Swag.registerHelpers hbs.handlebars
  hbs.registerPartials config.buckets.templatePath

  # formatTime helper
  hbs.registerHelper 'formatTime', (value, options) ->
    settings = _.defaults options.hash,
      format: 'MMM D, YYYY h:mma'

    moment(value).format(settings.format)

  Bucket.find {}, (err, buckets) ->

    # Add the entries helper
    hbs.registerAsyncHelper 'entries', (options, cb) ->
      settings = _.defaults options.hash,
        bucket: null
        until: Date.now()
        since: null
        limit: 10
        skip: 0
        status: 'live'
        sort: '-publishDate'
        status: 'live'
        find: ''
        slug: null

      searchQuery = {}
      bucketPath = path: 'bucket'

      if settings.bucket
        filteredBuckets = settings.bucket.split '|'
        filteredBucketIDs = _.pluck _.filter(buckets, (bkt) -> bkt.slug in filteredBuckets), '_id'
        searchQuery['bucket'] = $in: filteredBucketIDs

      if settings.slug
        searchQuery.slug = settings.slug

      if settings.where
        searchQuery.$where = settings.where

      if settings.status
        searchQuery.status = settings.status

      Entry.find searchQuery
        .populate 'bucket'
        .populate
          path: 'author'
          select: '-passwordDigest -resetPasswordToken -resetPasswordExpires'
        .sort settings.sort
        .limit settings.limit
        .skip settings.skip
        .exec (err, entries) ->
          console.log err if err
          return cb options.inverse @ if entries?.length is 0 or err

          ret = []
          for entry in entries

            # Make content attributes first-level tags, ie. `{{body}}` instead of `{{content.body}}`
            entryJSON = _.extend entry.toJSON(), entry.content
            delete entryJSON.content

            try
              ret.push options.fn entryJSON
            catch e
              console.log e

          cb ret.join('')
