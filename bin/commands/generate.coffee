inquirer = require 'inquirer'
path = require 'path'
fs = require 'fs-extra'

logger = require '../../server/lib/logger'

###
  Generate a Buckets project with a skeleton.

  @param {string} name - The name of the project.
###

module.exports = (opts) ->
  logger.warn 'Not implemented yet :/'

  opts.path ?= './'

  inquirer.prompt [
    type: 'input'
    name: 'project_name'
    message: 'Name of your project'
    default: 'my_buckets'
  ,
    type: 'input'
    name: 'directory'
    message: 'Directory to generate new Buckets app.'
    default: path.resolve './'
  ], (answers) ->
    console.log answers
    console.log fs.realpathSync answers.directory
    process.exit()
