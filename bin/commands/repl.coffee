###
 Enter a REPL session inside a Buckets CMS context.
###

module.exports = (opts) ->
  repl = require '../../node_modules/coffee-script/lib/coffee-script/repl'

  console.log "\n" + 'Buckets Command Line'.yellow
  console.log 'User, Bucket, Entry, and Route' + ' models have been loaded by default.'.grey
  console.log 'Type '.grey + '.help' + ' for a list of available commands.'.grey

  nodeRepl = require 'repl'

  replServer = repl.start
    prompt: '☮ ' # ⏚ ➙ ➜ ⎔ ⊔ ⏑ ↬ ☮ ➫ ➪ ➭ ⤻

  replServer.on 'exit', -> process.exit()

  replServer.context.Bucket = require '../../server/models/bucket'
  replServer.context.Entry = require '../../server/models/entry'
  replServer.context.User = require '../../server/models/user'
  replServer.context.Route = require '../../server/models/route'
