log = require("../utils/log")
_ = require("lodash")

###
Serve the local theme directory directly.

@param {num} port - The port to use. Defaults to 3000.
###
module.exports = (port) ->
  
  ###
  Coerce port to a number and check that it is a number.
  ###
  port = Number(port)
  port = 3000  if not _.isNumber(port) or _.isNaN(port)
  
  ###
  Currently unimplemented. :(
  ###
  log.warn "Not implemented yet. :("
  return
