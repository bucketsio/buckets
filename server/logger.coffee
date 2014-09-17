env = process.env.NODE_ENV || 'development'
winston = require 'winston'


config = {
  level: 'debug'
  colorize: env isnt 'production'
  silent: false
  timestamp: true
}

module.exports =  new (winston.Logger)({
  transports: [
    new (winston.transports.Console)(config)
  ]
})