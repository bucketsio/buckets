Chaplin = require 'chaplin'

module.exports = class CollectionView extends Chaplin.CollectionView
  itemRemoved: ->
  getTemplateFunction: -> @template
  fallbackSelector: '.fallback'
