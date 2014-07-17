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

  randomize = new Math.seedrandom email_hash or 'mrbucket'

  defaultColors = ['blue', 'red', 'green', 'yellow']
  color = defaultColors[Math.floor(defaultColors.length * randomize())]

  new Handlebars.SafeString """
    <div class="avatar avatar-#{color}"
      style="background-image: url(https://www.gravatar.com/avatar/#{email_hash}?d=404), url(/#{mediator.options.adminSegment}/img/avatars/#{color}.png)"></div>
  """

Handlebars.registerHelper 'highlightWildcards', (path) ->
  new Handlebars.SafeString( path
    .replace(/(\/?):([a-zA-Z0-9-_]*)\?/g, '<strong class="bkts-wildcard-optional show-tooltip" title="Optional parameter">$1$2</strong>')
    .replace(/\/:([a-zA-Z0-9-_]*)/g, '/<strong class="bkts-wildcard-param show-tooltip" title="Required parameter">$1</strong>')
    .replace('*', '<strong class="bkts-wildcard-catchall show-tooltip" title="Catch-all">…</strong>')
  )

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

Handlebars.registerHelper 'logo', ->
  new Handlebars.SafeString """
    <h1 id="logo">
      <a href="/#{mediator.options.adminSegment}/"><img src="/#{mediator.options.adminSegment}/img/buckets.svg" width="46" height="41"></a>
      <span class="version-badge">alpha</span>
    </h1>
  """

Handlebars.registerHelper 'statusColor', (status) ->
  statusToColor =
    live: 'primary'
    rejected: 'danger'
    pending: 'warning'
    draft: 'default'

  statusToColor[status]

Handlebars.registerHelper 'hasRole', (role..., options) ->
  if mediator.user?.hasRole role...
    options.fn @
  else
    options.inverse @
