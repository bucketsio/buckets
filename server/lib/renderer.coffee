Swag = require 'swag'
_ = require 'underscore'

config = require '../config'

Entry = require '../models/entry'
Bucket = require '../models/bucket'

module.exports = (hbs) ->

  # Add Swag helpers
  Swag.registerHelpers hbs.handlebars
  hbs.registerPartials config.buckets.templatePath

  Bucket.find {}, (err, buckets) ->

    # Add the entries helper
    hbs.registerAsyncHelper 'entries', (options, cb) ->
      settings = _.defaults options.hash,
        bucket: ''
        until: Date.now()
        since: ''
        limit: 10
        skip: 0
        sort: '-publishDate'
        status: 'live'
        find: ''
        slug: null

      searchQuery = {}
      bucketPath = path: 'bucket'

      if settings.bucket
        bucket = _.findWhere(buckets, slug: settings.bucket)

        searchQuery['bucket'] = bucket?._id

      if settings.slug
        searchQuery.slug = settings.slug

      if settings.where
        searchQuery.$where = settings.where

      Entry.find(searchQuery)
        .populate('bucket')
        .populate('author')
        .sort(settings.sort)
        .limit(settings.limit)
        .skip(settings.skip)
        .exec (err, pages) ->
          console.log err if err

          return cb options.inverse @ if pages?.length is 0 or err

          ret = []
          for page in pages
            try
              ret.push options.fn page.toJSON()
            catch e
              console.log e.stack, arguments

          cb ret.join('')
