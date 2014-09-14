<a href="http://buckets.io"><img src="http://buckets.io/images/buckets-logo.svg" height="80"></a>

A fast, simple way to build dynamic websites on top of [Express](http://expressjs.com/), [MongoDB](http://www.mongodb.org/), and [ElasticSearch](http://www.elasticsearch.org/). [More about our vision](docs/vision/vision.md).

[![Build Status](http://img.shields.io/travis/asm-products/buckets/master.svg?style=flat)](https://travis-ci.org/asm-products/buckets)
[![Dependencies](http://img.shields.io/david/asm-products/buckets.svg?style=flat)](https://david-dm.org/asm-products/buckets)
[![License](http://img.shields.io/npm/l/buckets.svg?style=flat)](LICENSE.md)
[![NPM](http://img.shields.io/npm/v/buckets.svg?style=flat)](https://www.npmjs.org/package/buckets)

# Getting Started

Buckets requires [Node.js](http://nodejs.org) (which comes with npm), and [MongoDB](http://www.mongodb.org) to be installed.

```
npm install buckets
```

You can also run the above command with `--save` to add Buckets to your app’s package.json. From here, you can run Buckets in a script like so:

```
buckets = require('buckets');
buckets({
  templatePath: __dirname + “/templates/“,
  publicPath: __dirname + “/public/“,
  // Additional configuration…
});
```

If you want plan on deploying to [Heroku](http://heroku.com/), you can also optionally use the button below to get started. This will install Buckets as well as set up any cloud services you need (like MongoDB). Note that you will still need to be comfortable with Git and npm modules in order to perform your own updates.

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)


## Heroku

The easiest way currently is to install on—as long as you have a Heroku account, you can simply use the button below:


Note: We aim to provide separate middleware to build into existing Express apps soon.

## From this repo

If you plan on contributing to Buckets' development, you can install and deploy Buckets directly from this repo.

### Pre-requirements

[MongoDB](http://www.mongodb.org), [Node.js](http://nodejs.org) and the following global:

```
npm install -g grunt-cli
```

Then install the local Node dependencies:

```
npm install
```

### Building

Now that everything is installed, you can build the Buckets source code by running `grunt`. This will build the client-side files for the Buckets admin panel, but unminified, and with source maps. If you'd like to see what the final client-side output will be, run `grunt prepublish` instead.

### Running

Once the source code has been built, you can run `npm start` to start the Buckets server and your site should be accessible at the default address: [http://localhost:3000/](http://localhost:3000/).

Alternatively, you could run `grunt start`—this also starts a server at the default address, but also watches all files for changes. Any changes to server CoffeeScript will restart the web server and then reload the browser. Any changes to client-side CoffeeScript, Stylus, or Handlebars will re-compile the appropriate files, then reload the browser.

There are a few other Grunt tasks available for [building](docs/frontend.md) and [running tests](docs/tests.md).

### Deploying

If you're deploying directly from this repo, you'll need to make one change to your local environment, which is to remove the `/public` from your `.gitignore` file. This is because we don't install Grunt or its dependencies in production environments to make everything faster/easier for people who install Buckets as an NPM module.

# Documentation

### Developer Documentation

* [Frontend Architecture](docs/frontend.md)
* [Database](docs/database.md)
* [Tests](docs/tests.md)
* [Migrations](docs/migrations.md)
* [Deploying to Heroku](docs/heroku.md)

### User Documentation

* [Routes](docs/user-docs/routes.md)
* [Templates](docs/user-docs/templates.md)

# Community

Follow along with Buckets’ progress and keep in touch with other Buckets users.

* Follow Buckets on [Twitter](http://twitter.com/bucketsio) and [Facebook](http://facebook.com/bucketsio)
* Keep up to date with [announcements](https://assembly.com/buckets/posts/) and track [project progress](https://assembly.com/buckets/wips) on Assembly.
* [Sign up](http://buckets.io) to be notified when Buckets is available for public beta.

### Contributing

This is a product being built by the [Assembly](https://assemblymade.com) community. You can help push this idea forward by visiting [https://assemblymade.com/buckets](https://assemblymade.com/buckets). We welcome any contributions to product design/direction or code.

Assembly products are made with contributions from the community. Assembly handles the boring stuff like hosting, support, financing, legal, etc. Once the product launches we collect the revenue and split the profits amongst the contributors.
