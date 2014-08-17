# Plugins (WORK IN PROGRESS)

Currently plugins are based on [NPM modules](https://www.npmjs.org). Plugin NPM names must take the form of `buckets-_name_`. The first example being developed is [buckets-location](http://github.com/davidkaneda/buckets-location/) which adds a Location FieldType.

Here’s the basic client API so far (some of this is just conceptual for now):

```
bkts.plugin('plugin_slug', {
  name: 'Plugin Name'
  config: // Underscore template (as a string) or Backbone/Chaplin View (you can require a class as well)
  input: // Underscore template (as a string) or Backbone/Chaplin View (you can require a class as well)
});
```

`bkts` is exposed to plugins as a global object, and is actually the `Application` instance of the running Buckets.

### CoffeeScript Support

By default, because plugin code is either built into JavaScript or run live on the server, CoffeeScript is supported by default.

### CommonJS Support

JavaScript or CoffeeScript files in your plugin have access to a `require` function. On the client-side, files are grouped together using browserify as they are built to be included in the app. On the server side (NodeJS) this is supported by default. This way, we can have a standard "manifest" file for the plugin both client and server-side (in `client.js` and `server.js`), but that manifest can import powerful libraries and classes.
