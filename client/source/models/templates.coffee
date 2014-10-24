BuildFiles = require 'models/buildfiles'

module.exports = class Templates extends BuildFiles
  build_env: 'live'
  url: "/api/buildfiles/live/?type=template"
