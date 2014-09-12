Swag = require 'swag'
_ = require 'underscore'
cloudinary = require 'cloudinary'
config = require '../config'
Entry = require '../models/entry'
Bucket = require '../models/bucket'
moment = require 'moment'
munge = require 'munge'

module.exports = (hbs) ->

  # Add Swag helpers
  Swag.registerHelpers hbs.handlebars
  hbs.registerPartials config.templatePath

  # formatTime helper
  hbs.registerHelper 'formatTime', (value, options) ->
    settings = _.defaults options.hash,
      format: 'MMM D, YYYY h:mma'

    moment(value).format(settings.format)

  # timeAgo helper
  hbs.registerHelper 'timeAgo', (value, options) ->
    moment(value).fromNow()

  # munge helper
  hbs.registerHelper 'munge', (value) ->
    new hbs.handlebars.SafeString munge value

  # entries helper
  hbs.registerAsyncHelper 'entries', (options, cb) ->

    Entry.findByParams options.hash, (err, entries) ->
      console.log err if err
      return cb options.inverse @ if entries?.length is 0 or err

      ret = []
      for entry in entries

        # Make content attributes first-level tags, ie. `{{body}}` instead of `{{content.body}}`
        entryJSON = _.extend entry, entry.content
        delete entryJSON.content

        try
          ret.push options.fn entryJSON
        catch e
          console.log e

      cb ret.join('')

  # inspect helper
  # Prints out pretty JSON (in pre tag) of passed arg or current scope
  hbs.registerHelper 'inspect', (thing, options) ->
    thing = @ unless thing? and options?

    entities =
      '<': '&lt;'
      '>': '&gt;'
      '&': '&amp;'

    json = JSON
      .stringify thing, null, 2
      .replace /[&<>]/g, (key) -> entities[key]

    new hbs.handlebars.SafeString "<pre>#{json}</pre>"

  hbs.registerHelper 'img', (img, options) ->
    return unless img?.public_id
    settings = _.defaults options.hash,
      fetch_format: 'auto'

    new hbs.handlebars.SafeString cloudinary.image(img.public_id, settings)
