# Buckets

## Manage content better.

Buckets is a simple, open source, content management system for Node.js.

[![Build Status](https://travis-ci.org/asm-products/buckets.svg?branch=master)](https://travis-ci.org/asm-products/buckets)

# Installing Buckets

### Pre-requirements

[MongoDB](http://www.mongodb.org), [Node.js](http://nodejs.org) and the following globals:


```
npm install -g  buckets grunt-cli
```

Then install the local Node dependencies:

```
npm install
```

### Running Buckets

At this point, you should be able to run:

```
buckets serve
```

After building, Buckets should then be accessible at the default address: [http://localhost:3000/](http://localhost:3000/)

### Running tests

- `buckets test:client`: To run client tests
- `buckets test:server`: To run server tests
- `buckets test`: To run both client and server tests

#### Additional Documentation

* [Frontend Architecture](docs/frontend.md)
* [Database](docs/database.md)
* [Deploying to Heroku](docs/heroku.md)

### Contributing

This is a product being built by the [Assembly](https://assemblymade.com) community. You can help push this idea forward by visiting [https://assemblymade.com/buckets](https://assemblymade.com/buckets). We welcome any contributions to product design/direction or code.

Assembly products are like open-source and made with contributions from the community. Assembly handles the boring stuff like hosting, support, financing, legal, etc. Once the product launches we collect the revenue and split the profits amongst the contributors.

One quick note on adding dependencies: First, you probably shouldn't have to add too many. But if you find yourself needing to `npm install awesome-sauce`, make sure you include either the `--save` flag (if the dependency will be needed in production) or `--save-dev` (if the dependency is only needed for testing/development).

[Or support Buckets via gittip :)](https://www.gittip.com/DavidKaneda/)
