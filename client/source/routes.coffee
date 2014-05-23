BucketSController = require 'controllers/buckets_controller'
InstallController = require 'controllers/install_controller'
AuthController = require 'controllers/auth_controller'

module.exports = (match) ->
  match 'install', 'install#firstuser', params: authRequired: no

  match 'login', 'auth#login', params: authRequired: no

  match '', 'buckets#dashboard'

  match ':missing*', 'bucket#missing'