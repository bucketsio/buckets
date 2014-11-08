winston = require 'winston'
config = require './config'

logger = new winston.Logger
  transports: [
    new winston.transports.Console
      colorize: yes
      level: config.get('logLevel')
  ,
    new winston.transports.File
      level: 'verbose'
      filename: "buckets.#{config.get('env')}.log"
      maxsize: 20000000 # 20mbish
      level: config.get('logLevel')
  ]

module.exports = logger
