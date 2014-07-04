env = process.env.NODE_ENV || 'development'
_ = require 'underscore'

config =
  default:
    buckets:
      adminSegment: 'admin'
      apiSegment: 'api'
      salt: 'BUCKETS4LIFE!!1'
      port: process.env.PORT || 3000
      env: env
      templatePath: "#{__dirname}/../user/templates/"
      catchAll: yes
    db: "mongodb://localhost/buckets_#{env}"
  production:
    smtp:
      service: 'Mandrill'
      port: 587
      host: 'smtp.mandrillapp.com'
      auth:
        user: process.env.MANDRILL_APIKEY
        pass: process.env.MANDRILL_USERNAME
    db: process.env.MONGOHQ_URL
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
