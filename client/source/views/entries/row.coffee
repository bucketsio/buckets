View = require 'lib/view'
tpl = require 'templates/entries/row'

module.exports = class EntryRow extends View
  template: tpl
  listen:
    'change model': 'render'
