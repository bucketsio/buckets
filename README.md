<a href="http://buckets.io"><img src="http://buckets.io/images/buckets-logo.svg" height="80"></a>

A fast, simple way to build dynamic websites on top of [Express](http://expressjs.com/), [MongoDB](http://www.mongodb.org/), and [ElasticSearch](http://www.elasticsearch.org/). [More about our vision](docs/vision/vision.md).

[![Build Status](http://img.shields.io/travis/asm-products/buckets/master.svg?style=flat)](https://travis-ci.org/asm-products/buckets)
[![Dependencies](http://img.shields.io/david/asm-products/buckets.svg?style=flat)](https://david-dm.org/asm-products/buckets)
[![License](http://img.shields.io/npm/l/buckets.svg?style=flat)](LICENSE.md)
[![NPM](http://img.shields.io/npm/v/buckets.svg?style=flat)](https://www.npmjs.org/package/buckets)

# Installing Buckets

There are several ways to install Buckets. Choose the path which is the easiest fit for your development environment.

## Heroku

The easiest way currently is to install on [Heroku](http://heroku.com/)—as long as you have a Heroku account, you can simply use the button below:

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

## NPM

To use Buckets directly from NPM, use:

```
npm install buckets --save
```

To add Buckets to your package.json. From here, you can run Buckets in your script like so:

```
buckets = require('buckets');
buckets({
  templatePath: __dirname + “/templates/“,
  publicPath: __dirname + “/public/“,
  // Additional configuration…
});
```

Note: We aim to provide separate middleware to build into existing Express apps soon.

## From this repo

If you plan on contributing to Buckets' development, you can install Buckets directly from this repo.

### Pre-requirements

[MongoDB](http://www.mongodb.org), [Node.js](http://nodejs.org) and the following global:

```
npm install -g grunt-cli
```

Then install the local Node dependencies:

```
npm install
```

At this point, you should be able to run:

```
grunt serve
```

After building, Buckets should then be accessible at the default address: [http://localhost:3000/](http://localhost:3000/). If you plan on working on Buckets source, you should [check out the other grunt tasks available](docs/frontend.md#grunt-tasks) for `dev` and `test` commands.

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