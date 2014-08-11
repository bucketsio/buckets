express = require 'express'
async = require 'async'
crypto = require 'crypto'

mailer = require '../../lib/mailer'
config = require '../../config'

User = require '../../models/user'

module.exports = app = express()

app.route('/users')
  .post (req, res) ->
    newUser = new User req.body

    newUser.save (err) ->
      return res.status(400).send err if err
      res.status(200).send newUser

  .get (req, res) ->
    User.find {}, (err, users) ->
      res.status(200).send users

app.route('/users/:userID')
  .get (req, res) ->
    User.findOne _id: req.params.userID, (err, user) ->
    res.send user if user

  .delete (req, res) ->
    User.remove _id: req.params.userID, (err) ->
      return res.status(400).send e: err if err
      res.status(200).end()

  .put (req, res) ->
    delete req.body._id
    User.findOne {_id: req.params.userID}, (err, user) ->
      return res.status(400).send e: err if err

      user.set(req.body).save (err, user) ->
        return res.status(400).send err if err
        res.status(200).send user

app.post '/forgot', (req, res) ->
  async.waterfall [
    (done) ->
      crypto.randomBytes 20, (err, buf) ->
        done err, buf?.toString('hex')
  ,
    (token, done) ->
      User.findOne email: req.body.email, (err, user) ->
        return res.send {error: 'No user with that email.'}, 404 unless user

        user.resetPasswordToken = token
        user.resetPasswordExpires = Date.now() + 3600000 # 1 hour

        user.save (err) -> done err, token, user
  ,
    (token, user, done) ->
      mailOptions =
        to: "#{user.name} <#{user.email}>"
        from: 'Buckets <noreply@buckets.io>'
        subject: 'Buckets Password Reset'
        text: """
          You are receiving this because you (or someone else) has requested the reset of the password for your account.\n
          Please click on the following link, or paste this into your browser to complete the process:\n
          http://#{req.headers.host}/#{config.buckets.adminSegment}/reset/#{token}\n\n
          If you did not request this, please ignore this email and your password will remain unchanged.\n
        """
      mailer.sendMail mailOptions, (err) ->
        done(err, 'done');
  ], (err) ->
    return res.send err, 400 if err
    res.send {}, 200

app.get '/reset/:token', (req, res) ->
  User.findOne resetPasswordToken: req.params.token, resetPasswordExpires: $gt: Date.now(), (err, user) ->
    return res.send 404 unless user

    res.send email: user.email, token: req.params.token

app.put '/reset/:token', (req, res) ->

  User.findOne resetPasswordToken: req.params.token, resetPasswordExpires: $gt: Date.now(), (err, user) ->
    return res.send 404 unless user

    console.log 'password', req.body.password

    user.password = req.body.password
    user.resetPasswordToken = undefined
    user.resetPasswordExpires = undefined

    user.validate (err) ->
      return res.send err, 400 if err

      user.save (err) ->
        return res.send err, 400 if err

        req.login user, (err) ->
          return res.send err, 400 if err

          res.send user, 200
