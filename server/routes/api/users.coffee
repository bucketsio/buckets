express = require 'express'
async = require 'async'
crypto = require 'crypto'

mailer = require '../../lib/mailer'
config = require '../../config'

User = require '../../models/user'

module.exports = app = express()


###
  @apiDefineErrorStructure UserNotFound
  @apiErrorExample Error-Response:
  HTTP/1.1 404 Not Found
  {
    "error": "UserNotFound"
  }
###

###
  @apiDefineSuccessStructure User
  @apiSuccessExample Success-Response:
  HTTP/1.1 200
  {
    "name": "David Kaneda",
    "email": "dave@buckets.io",
    "roles": [
      {
        "name": "administrator"
      }
    ],
    "date_created": "2014-08-16T05:26:40.285Z",
    "last_active": "2014-08-16T05:26:40.285Z",
    "email_hash": "4f731655f6de1f6728c716448e0ba634",
    "id": "53eeeb90605b111826ddd57a"
  }
###

###
  @apiDefineSuccessStructure Users
  @apiSuccessExample Success-Reponse:
  HTTP/1.1 200
  [
    {
      "name": "John Doe",
      "email": "dk+jd@morfunk.com",
      "activated": false,
      "roles": [],
      "date_created": "2014-08-17T09:45:34.230Z",
      "last_active": "2014-08-17T09:45:34.230Z",
      "email_hash": "64283570c25b53351129add2aba830fb",
      "id": "53f079bebabd1e1c98b718b9"
    },
    {
      "name": "Jane Doe",
      "email": "dk+jane@morfunk.com",
      "activated": false,
      "roles": [],
      "date_created": "2014-08-17T09:45:49.163Z",
      "last_active": "2014-08-17T09:45:49.163Z",
      "email_hash": "3161ceeed1a05982dd3a69e39b22320e",
      "id": "53f079cdbabd1e1c98b718bb"
    }
  ]
###

###
  @api {post} /users Add a User
  @apiVersion 0.0.4
  @apiGroup Users
  @apiName PostUser

  @apiParam {String} name Full name of the user.
  @apiParam {String} email Email address of the user.
  @apiParam {String} password Password for the user. Must be between 6-20 characters and include a number.

  @apiPermission administrator
###

###
  @api {get} /users Request Users
  @apiVersion 0.0.4
  @apiGroup Users
  @apiName GetUsers

  @apiPermission administrator
###

app.route('/users')
  .post (req, res) ->
    return res.status(401).end() unless req.user?.hasRole ['administrator']

    newUser = new User req.body

    newUser.save (err) ->
      return res.status(400).send err if err
      res.status(200).send newUser

  .get (req, res) ->
    User.find {}, (err, users) ->
      res.status(200).send users

###
  @api {get} /users/:id Request a User
  @apiVersion 0.0.4
  @apiGroup Users
  @apiName GetUser

  @apiParam {String} id User ID (sent in URL)

  @apiPermission administrator

  @apiSuccessStructure User
###

###
  @api {put} /users/:id Edit a User
  @apiVersion 0.0.4
  @apiGroup Users
  @apiName PutUser

  @apiParam {String} id User ID (sent in URL)
  @apiParam {String} [name] The full name of the user.
  @apiParam {String} [email] The user’s email address.

  @apiPermission administrator

  @apiParam (Changing password) {String} [password] The new password you would like to use.
  @apiParam (Changing password) {String} [passwordconfirm] The new password you would like to use.
  @apiParam (Changing password) {String} [oldpassword] Your current password.

  @apiSuccessStructure User

  @apiSuccessExample Success-Response:
    HTTP/1.1 200 OK
###

###
  @api {delete} /users/:id Delete a User
  @apiVersion 0.0.4
  @apiGroup Users
  @apiName DeleteUser

  @apiParam {String} id User ID (sent in URL)

  @apiPermission administrator

  @apiSuccessExample Success-Response:
    HTTP/1.1 204
###

app.route('/users/:userID')
  .get (req, res) ->
    User.findById req.params.userID, (err, user) ->
      res.send user if user

  .delete (req, res) ->
    return res.status(401).end() unless req.user?.hasRole ['administrator']

    User.remove _id: req.params.userID, (err) ->
      return res.status(400).send e: err if err
      res.status(200).end()

  .put (req, res) ->
    return res.status(401).end() unless req.user?.hasRole ['administrator'] or req.user?._id is req.params.userID

    User.findById req.params.userID, 'passwordDigest', (err, user) ->
      return res.status(400).send e: err if err

      {password, passwordconfirm, oldpassword} = req.body
      delete req.body.password # Only add back after checking below
      if password and passwordconfirm and oldpassword
        if password isnt passwordconfirm
          user.invalidate 'passwordconfirm', 'Your new password and confirmation don’t match.'
        else if not user.authenticate oldpassword
          user.invalidate 'oldpassword', 'The provided password is incorrect.'
        else
          # All good
          req.body.password = password

      user.set(req.body).save (err, user) ->
        return res.status(400).send err if err
        res.status(200).send user

###
  @api {post} /forgot Request a Password Reset
  @apiDescription Will look for the provided email, generate a reset token, and send a password reset email to the matching user.
  @apiVersion 0.0.4
  @apiGroup Users
  @apiName ResetPassword

  @apiParam {String} email User’s email address

  @apiErrorStructure UserNotFound
  @apiErrorExample Error-Response:
    HTTP/1.1 400

###

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
          http://#{req.headers.host}/#{config.adminSegment}/reset/#{token}\n\n
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
    return res.status(404).end() unless user

    user.password = req.body.password
    user.resetPasswordToken = undefined
    user.resetPasswordExpires = undefined

    user.validate (err) ->
      return res.status(400).send err if err

      user.save (err) ->
        return res.status(400).send err if err

        req.login user, (err) ->
          return res.status(400).send err if err

          res.status(200).send user
