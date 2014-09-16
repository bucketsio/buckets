winston = require 'winston'


config = {
  level: 'debug'
  colorize: true
  silent: false
  timestamp: true
}

module.exports =  new (winston.Logger)({
  transports: [
    new (winston.transports.Console)(config)
  ]
})