log = require "../utils/log"
repl = require "repl"

###
Custom REPL eval for Buckets.
###
bucketsEval = (cmd, context, filename, callback) ->
  callback null, result

###*
Enter a REPL session inside a Buckets CMS context.
###
module.exports = ->
  log.info "Starting Buckets REPL..."

  r = repl.start
    prompt: "Buckets => "
    # eval: bucketsEval,

  r.context.package = require("../../package.json")

  r.on "exit", ->
    log.info "See you around!"
    process.exit 0

