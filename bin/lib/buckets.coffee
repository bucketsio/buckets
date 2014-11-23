buckets = require 'nomnom'
logger = require '../../server/lib/logger'

###
  Define commands.
###

buckets
  .script 'buckets'
  .help '''
usage help
  buckets <command> -h

issues
  Please report any issues to:
  https://assembly.com/buckets
  '''

runCommand = (opts)->
  try
    require("../commands/#{opts[0]}")(opts)
  catch e
    console.log e
    logger.error 'Could not load that command.', error: e

buckets
  .command 'generate'
  .help 'Generate a Buckets skeleton project.'
  .option 'name',
    position: 1
    required: true
    help: 'The name of your project.'
  .callback runCommand

buckets
  .command 'serve'
  .help 'Serve the local theme directory.'
  .option 'port',
    position: 1
    required: false
    help: 'The port to run on. Defaults to 3000.'
  .callback runCommand

buckets
  .command 'repl'
  .help 'Enter a Buckets REPL environment.'
  .callback runCommand

# Nom nom
buckets.nom()
