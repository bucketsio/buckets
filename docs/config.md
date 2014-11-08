# Buckets Configuration

Buckets provides a few ways to set configuration options when starting up. You can provide these settings directly to the `buckets` function, or you can set ENV variables. Buckets will also look for two JSON files at the root of your project, both a `config.json` and an `_environment_.json` (where environment is whatever environment is currently active).

Here are the settings:

## Guide

### name `process.env.GLOBAL_NAME` _default_

## Settings

### autoStart _true_

Set to false to include Buckets as Middleware.

### adminSegment _'admin'_

The URL segment at which the server will serve the Buckets admin interface.

### apiSegment _'api'_

The URL segment at which the server will serve the Buckets [API](../api/).

### cloudinary `CLOUDINARY_URL`

The connection URL for [Cloudinary](http://cloudinary.com/). Set up for default Heroku installation.

### db `MONGOHQ_URL` _'mongodb://localhost/buckets_#{env}'_

A MongoDB connection string. The env variable is set up for a default Heroku installation.

### fastlyApiKey `FASTLY_API_KEY`

For Fastly CDN support.

### fastlyServiceId `FASTLY_SERVICE_ID`

For Fastly CDN support.

### fastlyCdnUrl `FASTLY_CDN_URL`

For Fastly CDN support.

### port `PORT` _3000_

Port at which Buckets serves the website.

### logLevel _'info'_

The level at which the logger reports. Possible values are "none", "debug", "verbose", "info", "warn", and "error".

### pluginsPath _'./node_modules/'_

Path to where plugins are loaded from. All plugins are node modules with a naming convention of "buckets-_name_".


#### smtp.service _'GMAIL'_

#### smtp.auth.user `MANDRILL_USERNAME`

#### smtp.auth.pass `MANDRILL_APIKEY`

