ErrorController = require 'controllers/error_controller'
SettingsController = require 'controllers/settings_controller'
TemplatesController = require 'controllers/templates_controller'
BucketsController = require 'controllers/buckets_controller'
InstallController = require 'controllers/install_controller'
RoutesController = require 'controllers/routes_controller'
AuthController = require 'controllers/auth_controller'
HelpController = require 'controllers/help_controller'

module.exports = (match) ->
  match 'install', 'install#firstuser', params: authRequired: no
  match 'login', 'auth#login', params: authRequired: no
  match 'reset/:token', 'auth#resetPassword', params: authRequired: no

  match 'buckets/add', 'buckets#add'
  match 'buckets/:slug', 'buckets#browse'
  match 'buckets/:slug/add', 'buckets#browse', params: add: yes
  match 'buckets/:slug/fields', 'buckets#editFields'
  match 'buckets/:slug/settings/members', 'buckets#settings', params: activeTab: 3
  match 'buckets/:slug/settings/fields', 'buckets#settings', params: activeTab: 2
  match 'buckets/:slug/settings', 'buckets#settings', params: activeTab: 1

  match 'buckets/:slug/:entryID', 'buckets#browse'

  match 'templates(/*filename)', 'templates#edit'
  match 'routes', 'routes#list'

  match 'help(/*doc)', 'help#index'

  match 'settings', 'settings#basic'
  match 'users(/:email)', 'settings#users'

  match '', 'buckets#dashboard'

  match ':missing*', 'buckets#missing'
