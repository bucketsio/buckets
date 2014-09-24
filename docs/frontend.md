# Buckets Frontend

**Buckets employs an opinionated approach to the frontend developer stack, and makes strong use of [Grunt](http://gruntjs.com) for building and running tasks.** External dependencies are handled with [Bower](http://bower.io). The frontend is written in [CoffeeScript](http://coffeescript.org) in `client/source` and makes use of [CommonJS](http://wiki.commonjs.org/wiki/CommonJS)-style requires (which are compiled by [Browserify](http://browserify.org). Although this leads to highly abstracted JavaScript, source maps are generated at every step, so debugging in the browser directly shows CoffeeScript files and line numbers. Additionally, LiveReload (and reloading the Node server), is built directly into the `grunt start` process (see below).

### Grunt Tasks

Once you’ve installed the project dependencies, use Grunt.js to build, serve, and test Buckets.

* `grunt` (default) — Builds a development version of Buckets (unminified, with source maps).
* `grunt prepublish` (default) — Builds a production version of Buckets (minified).
* `grunt start` — **This’ll be your main jam.** Creates a local server (localhost:3000) and runs “watch” for all files. Any changes to server CoffeeScript will restart the Node server and then reload the browser. Any changes to client-side CoffeeScript, Stylus, or Handlebars will re-compile, then reload the browser.
* `grunt dev` — Shortcut for `grunt && grunt start`

There are also specific [Grunt tasks for testing](./tests.md).

### Backbone & Chaplin

The app uses [Chaplin](http://chaplinjs.org) to organize its architecture, which sits on top of [Backbone](http://backbonejs.org). Chaplin simply provides a few enhancements to vanilla Backbone, most notably around providing a Routes/Controller mapping, and automatic view disposal and memory management.

The lifecycle of a general frontend request is fairly easy to follow. Simply find the corresponding Route in `client/source/routes.coffee`, which will point to the Controller/Action combination. Controllers are located in `client/source/controllers`, and a typical action will initialize a model or collection, and render a view. Disposing the previous controller’s View and data models is all handled automatically.

### Bootstrap 3

For CSS, the app is currently being written in Stylus, though most basic UI styles are provided by Bootstrap 3 (with custom variables) at `client/style/bootstrap.less`.

_Currently we are including all styles and JavaScript plugins, though we will be trimming out unused modules before beta._

### Handlebars

Templates are written in [Handlebars](http://handlebarsjs.com) and pre-compiled with Grunt. We also automatically include [Swag](https://github.com/elving/swag), which provides a number of useful helpers out-of-the-box. Additional custom helpers can be found in `client/source/helpers.coffee`.

### Fontastic Icon Font

We’re currently using icons from [Fontastic](http://fontastic.me), including [Streamline Icons](http://www.streamlineicons.com), please contact [David Kaneda](http://davidkaneda.com) with suggestions for changes.

### Bower

All 3rd-party client-side libraries are loaded via [Bower](http://bower.io). We make heavy use of the `exportsOverride` parameter in `bower.json` to load specific files out of the Bower components, as needed. Certain Bower components are excluded from being exported altogether. Some of these are application-specific libraries (like Chaplin and Backbone), which are dynamically compiled into the app through the `browserify` task (see the `alias` option in the Gruntfile), while others—like the Ace Text Editor—are large in size, and only loaded when needed within the app (using [Modernizr.load](http://modernizr.com/docs/#load).

#### Vendor Bower Libraries

* [Moment](http://momentjs.com)
* [Ladda buttons](http://lab.hakim.se/ladda/)
* [Toastr (notifications)](https://github.com/CodeSeven/toastr)
* [jQuery formParams](http://api.jquery.com/jquery.param/)
* [Ace Editor](http://ace.c9.io)
