_ = require 'underscore'

Chaplin = require 'chaplin'
Cocktail = require 'cocktail'

module.exports = class View extends Chaplin.View
  autoRender: yes
  mixins: []
  getTemplateFunction: -> @template
  getTemplateHTML: -> @getTemplateFunction() @getTemplateData()

  initialize: ->
    Cocktail.mixin @, mixin for mixin in @mixins

  # Don't hate the player, hate the game
  getSize: ->
    width = $(window).width()

    # From bootstrap/less/variables.less
    if width < 768
      'xs'
    else if 768 <= width < 992
      'sm'
    else if 992 <= width < 1200
      'md'
    else
      'sm'

  dispose: ->
    @trigger 'dispose'
    super
