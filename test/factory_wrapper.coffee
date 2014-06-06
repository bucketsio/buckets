Factory = require('rosie').Factory

module.exports = (name, attributes) ->
  obj = Factory.define(name)

  for k, v of attributes
    obj.attr(k, v)

  obj
