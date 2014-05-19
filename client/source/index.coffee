Chaplin = require 'chaplin'
Horse = require './horse'
Cow = require './cow'

module.exports = class App extends Chaplin.Application
  constructor: ->
    h = new Horse
    console.log 'horse', h
    h.speak()

    c = new Cow
    c.speak()

#
window.app = new App