Handlebars = require 'hbsfy/runtime'
mediator = require 'mediator'

Swag.registerHelpers Handlebars

Handlebars.registerHelper 'adminSegment', ->
  mediator.options.adminSegment

Handlebars.registerHelper 'icon', (type) ->
  new Handlebars.SafeString """<span class="icon buckets-icon-#{type}"></span>"""

Handlebars.registerHelper 'input', (type, name, options) ->
  
  placeholder = if options.hash?.placeholder
    " placeholder=\"#{options.hash.placeholder}\""
  else
    ''

  idAttr = if options.hash?.id
    " id=\"#{options.hash.id}\""
  else
    ''

  value = if options.hash?.value
    " value=\"#{options.hash.value}\""
  else
    ''

  sluggify = if options.hash?.sluggify
    " data-sluggify=\"#{options.hash.sluggify}\""
  else
    ''

  new Handlebars.SafeString """
    <div class="form-group">
      <input type="#{type}" name="#{name}" class="form-control"#{placeholder}#{idAttr}#{value}#{sluggify}>
    </div>
  """

Handlebars.registerHelper 'submit', (options) ->
  text = options.hash?.text or 'Submit'

  new Handlebars.SafeString """
    <button class="btn btn-primary ladda-button" data-style="zoom-in" type="submit">#{text}</button>
  """

Handlebars.registerHelper 'gravatar', (email_hash) ->
  new Handlebars.SafeString """
    <div class="avatar" style="background-image: url(http://www.gravatar.com/avatar/#{email_hash})"></div>
  """

Handlebars.registerHelper 'debug', ->
  console.log @, arguments