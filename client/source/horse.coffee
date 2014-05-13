Animal = require './animal'

module.exports = class Horse extends Animal
  speak: -> 
    console.log 'Neigh'

    # This debugger is simply to show source-mapping in Chrome
    debugger