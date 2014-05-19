BucketController = require 'controllers/bucket_controller'
InstallController = require 'controllers/install_controller'

module.exports = (match) ->
  match 'install/', 'install#start'
  match '', 'bucket#list'
  match ':missing*', 'bucket#missing'