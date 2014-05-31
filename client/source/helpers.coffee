Handlebars = require 'hbsfy/runtime'
mediator = require('chaplin').mediator
_ = require 'underscore'
require 'helpers/forms'

Swag.registerHelpers Handlebars

Handlebars.registerHelper 'adminSegment', ->
  mediator.options.adminSegment

Handlebars.registerHelper 'icon', (type) ->
  new Handlebars.SafeString """<span class="icon buckets-icon-#{type}"></span>"""

Handlebars.registerHelper 'gravatar', (email_hash) ->
  new Handlebars.SafeString """
    <div class="avatar" style="background-image: url(https://www.gravatar.com/avatar/#{email_hash})"></div>
  """

Handlebars.registerHelper 'highlightWildcards', (path) ->
  new Handlebars.SafeString path.replace /\/:([a-zA-Z0-9-_]*)/g, '/<strong class="bkts-wildcard">:$1</strong>'

Handlebars.registerHelper 'dumbBlankSlate', (itemName) ->
  new Handlebars.SafeString _.sample [
    "It’s 10 o’clock, do you know where your #{itemName} are?"
  ,
    "#{itemName} PLZ"
  ,
    "Now if only we had #{itemName}…"
  ,
    "If I had a dime for every #{itemName}… I’d be broke."
  ]

Handlebars.registerHelper 'timeAgo', (dateTime) ->
  m = moment dateTime
  expanded = Handlebars.helpers.simpleDateTime dateTime

  o = []
  o.push """<span title="#{expanded}">"""
  o.push moment(dateTime).fromNow()
  o.push "</span>"

  new Handlebars.SafeString o.join ''

Handlebars.registerHelper 'simpleDateTime', (dateTime) ->
  m = moment dateTime
  m.format 'MMMM Do YYYY, h:mma'

Handlebars.registerHelper 'debug', ->
  console.log @, arguments

Handlebars.registerHelper 'hasRole', ->
  a = Array::slice.call(arguments)
  options = a.pop()

  if !!mediator.user && mediator.user.hasRole.apply(mediator.user, a)
    options.fn(@)

