convict = require 'convict'
fs = require 'fs-extra'

logger = require './logger'

config = convict
  autoStart:
    doc: 'Should the app start listenening? (Pass no to use as middleware)'
    format: Boolean
    default: yes
  adminSegment:
    doc: 'The URL segment which serves the Buckets admin.'
    format: String
    default: 'admin'
  apiSegment:
    doc: 'The URL segment which serves the API.'
    default: 'api'
  buildsPath:
    doc: 'Path to local development theme.'
    format: String
    default: './builds/'
  cloudinary:
    doc: 'Cloudinary API URL for image uploads.'
    env: 'CLOUDINARY_URL'
    default: ''
    format: String
  db:
    doc: 'A MongoDB connection string.'
    format: String
    default: "mongodb://localhost/buckets_development"
    env: 'MONGOHQ_URL'
  env:
    doc: 'The app environment.'
    format: ['production', 'development', 'test']
    default: 'development'
    env: 'NODE_ENV'
  fastlyApiKey:
    env: 'FASTLY_API_KEY'
    default: false
  fastlyServiceId:
    env: 'FASTLY_SERVICE_ID'
    default: false
  fastlyCdnUrl:
    env: 'FASTLY_CDN_URL'
    default: false
  logLevel:
    doc: 'What level for the logs.'
    format: ['none', 'debug', 'verbose', 'info', 'warn', 'error']
    default: 'info'
  pluginsPath:
    doc: 'Path to where plugins are loaded from.'
    default: "#{__dirname}/../../node_modules/"
  port:
    doc: 'The port to bind to.'
    format: 'port'
    default: 3000
    env: 'PORT'
  salt:
    doc: 'A private salt used to obscure tokens and passwords.'
    default: 'BUCKETS4LIFE!!1'
    format: String
    env: 'BUCKETS_SALT'
  smtp:
    service:
      doc: 'Nodemailer service type for sending email.'
      format: String
      default: ''
    auth:
      user:
        doc: 'SMTP Username'
        format: String
        env: 'MANDRILL_USERNAME'
        default: ''
      pass:
        doc: 'SMTP Password'
        format: String
        env: 'MANDRILL_APIKEY'
        default: ''

if fs.existsSync "./config/config.json"
  logger.info 'Loading config from config/config.json'
  config.loadFile "./config/config.json"

if fs.existsSync "./config/#{config.get('env')}.json"
  logger.info "Loading config from config/#{config.get('env')}.json"
  config.loadFile "./config/#{config.get('env')}.json"

config.validate()

module.exports = config
