Animal = require './animal'

module.exports = class Cow extends Animal
  speak: -> console.log 'moo'