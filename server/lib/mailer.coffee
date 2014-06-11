nodemailer = require 'nodemailer'
config = require '../config'

module.exports = nodemailer.createTransport('SMTP', config.smtp);