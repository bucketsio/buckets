config = require '../config'
winston = require 'winston'

level = config.logLevel

logger = new winston.Logger
  transports: [
    new winston.transports.Console
      colorize: yes
      level: level
  ,
    new winston.transports.File
      level: 'verbose'
      filename: "buckets.#{config.env}.log"
      maxsize: 20000000 # 20mbish
  ]

module.exports = logger
