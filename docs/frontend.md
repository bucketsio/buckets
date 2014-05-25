# Buckets Frontend

Buckets employs an opinionated approach to the frontend developer stack, made possible by [Grunt](http://gruntjs.com). External dependencies are handled with [Bower](http://bower.io). The frontend is written in [CoffeeScript](http://coffeescript.org) in `client/source` and makes use of [CommonJS](http://wiki.commonjs.org/wiki/CommonJS)-style requires (which are compiled by Browserify). Although this leads to highly abstracted JavaScript, source maps are generated at every step, so debugging in the browser directly shows CoffeeScript files and line numbers. For CSS, the app is currently being written in Styus, though most basic UI styles are provided by Bootstrap 3 (with custom variables at `client/style/bootstrap.less`. Additionally, LiveReload (and reloading the Node server), is built directly into the Grunt `dev` process (see below).

### Grunt Tasks

Once you’ve installed the project dependencies, use Grunt.js to build, serve, develop, or test Buckets.

* `grunt dev` — **This’ll be your main jam.** Creates a local server (localhost:3000) and runs “watch” for all files. Any changes to server CoffeeScript will restart the Node server and then reload the browser. Any changes to client-side CoffeeScript, Stylus, or Handlebars will re-compile, then reload the browser.
* `grunt build` (default) — Prepares to deploy a development branch of Buckets.
* `grunt serve` — Does a standard build, minifies the assets, and serves the app.

### Icons

We’re currently using icons from [Fontastic](http://fontastic.me), including [Streamline Icons](http://www.streamlineicons.com), please contact [David Kaneda](http://davidkaneda.com) with suggestions for changes.