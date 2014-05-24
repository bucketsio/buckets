# Buckets

## Manage content better.

This is a product being built by the Assembly community. You can help push this idea forward by visiting [https://assemblymade.com/buckets](https://assemblymade.com/buckets).


# Installing Buckets

### Pre-requirements

[RethinkDB](http://rethinkdb.com), [Node.js](http://nodejs.org) and the following globals:


```
  brew install protobuff
```


```
	npm install -g grunt-cli
```

Then install the local Node dependencies:

```
	npm install
```

### General Development Environment

Buckets employs an opinionated approach to the frontend developer stack, made possible by Grunt. External dependencies are handled with [Bower](http://bower.io). The frontend is written in CoffeeScript in `client/source` and makes use CommonJS-style includes (which are then compiled by Browserify). Although this leads to highly abstracted JavaScript, source maps are generated at every step, so debugging in the browser will directly show CoffeeScript files and line numbers. Additionally, LiveReload (and reloading the Node server), is built into the Grunt `dev` process (see below).

### Primary Grunt Tasks

Once you’ve installed the project dependencies, use Grunt.js to build, serve, develop, or test Buckets.

* `grunt build` (default) — Prepares to deploy a development branch of Buckets.
* `grunt dev` — Creates a local server (localhost:3000) and runs “watch” for all files. Any changes to server CoffeeScript will restart the Node server and then reload browser window. Any changes to client-side CoffeeScript, Stylus, or Handlebars will re-compile, then reload the browser.
* `grunt serve` — Does a standard build, minifies the assets, and serves the app.

### How Assembly Works

Assembly products are like open-source and made with contributions from the community. Assembly handles the boring stuff like hosting, support, financing, legal, etc. Once the product launches we collect the revenue and split the profits amongst the contributors.

Visit [https://assemblymade.com](https://assemblymade.com) to learn more.
