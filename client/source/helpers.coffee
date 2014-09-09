Handlebars = require 'hbsfy/runtime'
mediator = require 'mediator'
_ = require 'underscore'
moment = require 'moment'

require 'helpers/forms'

Swag.registerHelpers Handlebars

Handlebars.registerHelper 'adminSegment', ->
  mediator.options.adminSegment

Handlebars.registerHelper 'icon', (type) ->
  new Handlebars.SafeString """<span class="icon buckets-icon-#{type}"></span>"""

Handlebars.registerHelper 'helpIcon', (tooltip, options) ->
  new Handlebars.SafeString if options.hash?.docsPath
    """<a class="btn btn-small btn-help btn-link btn-icon btn-icon-small show-tooltip" title="#{tooltip}" href="/#{mediator.options.adminSegment}/help/#{options.hash.docsPath}" target="_blank">#{Handlebars.helpers.icon 'question'}</a>"""
  else
    """<span class="btn-icon btn-help btn-icon-small show-tooltip" title="#{tooltip}">#{Handlebars.helpers.icon 'question'}</span>"""

Handlebars.registerHelper 'gravatar', (email_hash) ->

  randomize = new Math.seedrandom email_hash or 'mrbucket'

  defaultColors = ['blue', 'red', 'green', 'yellow']
  color = defaultColors[Math.floor(defaultColors.length * randomize())]

  new Handlebars.SafeString """
    <div class="avatar avatar-#{color}" style="background-image: url(https://www.gravatar.com/avatar/#{email_hash}?d=404), url(/#{mediator.options.adminSegment}/img/avatars/#{color}.png)"></div>
  """

Handlebars.registerHelper 'renderRoute', (keys) ->
  url = @urlPattern

  highlightedKeys = []
  for key in @keys
    continue if key.name in highlightedKeys
    url = url.replace ///:#{key.name}\??\*?\+?(\(.+\))?///g, (match, regex) ->
      className = 'show-tooltip bkts-wildcard'
      className += ' bkts-wildcard-optional' if key.optional
      highlightedKeys.push key.name
      """
        <strong class="#{className}" title="#{match}">#{key.name}</strong>
      """

  new Handlebars.SafeString url

Handlebars.registerHelper 'timeAgo', (dateTime) ->
  m = moment dateTime
  expanded = Handlebars.helpers.simpleDateTime dateTime

  new Handlebars.SafeString """
    <span title="#{expanded}" class="show-tooltip">#{moment(dateTime).fromNow()}</span>
  """

Handlebars.registerHelper 'simpleDateTime', (dateTime) ->
  m = moment dateTime
  m.format 'MMMM Do YYYY, h:mma'

Handlebars.registerHelper 'debug', ->
  console.log @, arguments

Handlebars.registerHelper 'logo', ->
  new Handlebars.SafeString """
    <h1 id="logo">
      <a href="/#{mediator.options.adminSegment}/"><img src="/#{mediator.options.adminSegment}/img/buckets.svg" width="200"></a>
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

