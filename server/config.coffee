env = process.env.NODE_ENV || 'development'
_ = require 'underscore'

config =
  default:
    adminSegment: 'admin'
    apiSegment: 'api'
    salt: 'BUCKETS4LIFE!!1'
    port: process.env.PORT || 3000
    env: env
    templatePath: "#{__dirname}/../user/templates/"
    publicPath: "#{__dirname}/../user/public/"
    pluginsPath: "#{__dirname}/../node_modules/"
    catchAll: yes
    autoStart: yes
    cloudinary: process.env.CLOUDINARY_URL
    db: "mongodb://localhost/buckets_#{env}"
  production:
    smtp:
      service: 'Mandrill'
      auth:
        user: process.env.MANDRILL_USERNAME
        pass: process.env.MANDRILL_APIKEY
    db: process.env.MONGOHQ_URL
    fastly:
      api_key: process.env.FASTLY_API_KEY
      cdn_url: process.env.FASTLY_CDN_URL
      service_id: process.env.FASTLY_SERVICE_ID
  development:
    smtp:
      service: 'Gmail'
      auth:
        user: 'your.email@gmail.com'
        pass: 'PASSWORD'

module.exports = if config[env]?
  _.defaults(config[env], config.default)
else
  config.default
