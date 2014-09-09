express = require 'express'
hbs = require 'hbs'
cloudinary = require 'cloudinary'
url = require 'url'
cors = require 'cors'
glob = require 'glob'
fs = require 'fs'
favicon = require 'serve-favicon'
_ = require 'underscore'
marked = require 'marked'

config = require '../config'
plugins = require '../lib/plugins'
passport = require '../lib/auth'
pkg = require '../../package'
User = require '../models/user'

module.exports = app = express()

{adminSegment} = config

hbs.registerHelper 'json', (context) ->
  new hbs.handlebars.SafeString JSON.stringify(context)

app.set 'views', "#{__dirname}/../views"

faviconFile = "#{__dirname}/../../public/favicon.ico"
app.use favicon faviconFile if fs.existsSync faviconFile

app.get '/*.(woff|ttf|eot|otf)', cors()
app.use express.static "#{__dirname}/../../public/", maxAge: 86400000 * 7 # One week

app.set 'plugins', plugins.load()

# Special case for install
app.post '/login', passport.authenticate('local', failureRedirect: "/#{adminSegment}/login"), (req, res, next) ->
  res.redirect if req.user and req.body.next
    req.body.next
  else
    "/#{adminSegment}/"

app.post '/checkLogin', (req, res) ->
  passport.authenticate('local', (err, user, authErr) ->
    if authErr
      res.status(401).send errors: [authErr]
    else if user
      res.status(200).end()
    else
      res.status(500).send err
  )(req, res)

app.get '/logout', (req, res) ->
  req.logout()
  res.redirect "/#{adminSegment}/"

app.get "/help-html/*", (req, res, next) ->
  glob "../../docs/user-docs/#{req.params[0]}", cwd: __dirname, (e, files) ->
    return res.status(404).end() unless files.length
    fs.readFile "#{__dirname}/#{files[0]}", encoding: 'utf-8', (e, content) ->
      return res.status(400).end() unless content and html = marked(content)
      res.status(200).send html

app.get '/:admin*?', (req, res) ->
  # Todo: Don't do install check if user exists (obviously false)
  User.count({}).exec (err, userCount) ->
    res.send 500 if err

    localPlugins = _.filter app.get('plugins'), (plugin) ->
      plugin.client or plugin.clientStyle

    if config.cloudinary
      parsed = url.parse(config.cloudinary)
      [api_key,api_secret] = parsed.auth.split(':')
      cloud_name = parsed.host

      cloudinaryData =
        timestamp: Date.now() # Lasts 1 hour
        use_filename: yes
        callback: "http://#{req.get('host')}/vendor/cloudinary_js/html/cloudinary_cors.html"
        image_metadata: yes
        exif: yes
        colors: yes
        faces: yes
        eager: 'c_limit,w_600,h_300,f_auto'
        eager_async: yes

      signature = cloudinary.utils.sign_request cloudinaryData,
        cloud_name: cloud_name
        api_key: api_key
        api_secret: api_secret
      .signature
      cloudinaryData.signature = signature
      cloudinaryData.api_key = api_key
      cloudinaryData.cloud_name = cloud_name
    else
      cloudinaryData = {}

    res.render 'admin',
      user: req.user
      env: config.env
      plugins: localPlugins
      adminSegment: adminSegment
      assetPath: if config.fastly?.cdn_url and config.env is 'production'
          "http://#{config.fastly.cdn_url}/#{adminSegment}"
        else
          "/#{adminSegment}"
      apiSegment: config.apiSegment
      needsInstall: userCount is 0
      cloudinary: cloudinaryData
      version: pkg.version

    if req.user
      req.user.last_active = Date.now()
      req.user.save()
