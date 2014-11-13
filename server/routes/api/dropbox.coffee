express = require 'express'
passport = require 'passport'
DropboxStrategy = require('passport-dropbox').Strategy
dbox = require 'dbox'
config = require '../../lib/config'

module.exports = app = express()

if process.env.DROPBOX_APP_KEY and process.env.DROPBOX_APP_SECRET and process.env.DROPBOX_CALLBACK_URL

  passport.use new DropboxStrategy
    consumerKey: process.env.DROPBOX_APP_KEY
    consumerSecret: process.env.DROPBOX_APP_SECRET
    callbackURL: process.env.DROPBOX_CALLBACK_URL
    passReqToCallback: yes
  , (req, token, tokenSecret, profile, done) ->
    return done null, false unless req?.user and token and tokenSecret and profile?.id
    console.log 'Adding Dropbox to user'
    req.user.dropbox =
      id: profile.id
      displayName: profile.displayName
      token: token
      tokenSecret: tokenSecret
      meta: profile._json

    delete profile._raw
    delete profile._json

    req.user.save done

    # background async for now (todo: pubsub)
    req.user.initializeDropbox req.hostname

  app.get '/connect/dropbox', passport.authorize('dropbox')

  app.get '/disconnect/dropbox', (req, res, next) ->
    console.log 'Disconnecting user', req.user
    if req.user?.dropbox
      req.user.dropbox = null
      req.user.save (e, user) ->
        res.status(200).end()
    else
      res.status(400).end()

  app.get '/auth/dropbox/callback',
    passport.authorize 'dropbox',
      failureRedirect: "/#{config.get('adminSegment')}/nope"
  , (req, res) ->
    res.redirect "/#{config.get('adminSegment')}/users/#{req.user.email}"
