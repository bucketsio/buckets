Handlebars = require 'hbsfy/runtime'
mediator = require 'mediator'

Handlebars.registerHelper 'adminSegment', ->
  mediator.options.adminSegment