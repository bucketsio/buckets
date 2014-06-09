# Buckets Tests and Code Coverage

**Buckets doesn't view tests and code coverage as silver bullets, but we think they're an important way to demonstrate the app's robustness and to on-board new contributors. We use [Mocha](http://visionmedia.github.io/mocha/) for testing across the stack, [Chai](http://chaijs.com) for assertions, [Sinon](http://sinonjs.org) for stubs and spies, [SuperTest](https://github.com/visionmedia/supertest) for requests, and [Rosie](https://github.com/bkeepers/rosie) for creating test objects. NB: [Chrome](https://www.google.com/intl/en-US/chrome/browser/) is required for client-side testing.

### Run the Tests

`npm test` will run server- and client-side tests.

You can also run the specific Grunt tasks associated with each kind of test. For example, running `grunt test:server:cov` will run the server tests and print a coverage report. See the [Gruntfile](Gruntfile.coffee) for more info.

### Mocha Tests

It's probably easiest to just check out [the docs](http://visionmedia.github.io/mocha/), but in short, Mocha provides `describe` and `it` blocks, as well as `before[Each]` and `after[Each]` hooks to provide an easy-to-use (if not downright familiar) testing interface. Test async code by passing a `done` function into the `it` callback.

### Chai Assertions

We use the [`expect`](http://chaijs.com/guide/styles/) assertion style, which provides convenient and easy-to-read methods around your tests' assertions.

### Sinon

Need to test error handling? Need to mock out a call for one of your tests? Need to make sure a callback is called? [Sinon](http://sinonjs.org) spies and stubs have become something of a standard. You can see examples of their usage in [templates.coffee](test/server/routes/api/templates.coffee#L30).

### SuperTest

[SuperTest](https://github.com/visionmedia/supertest) makes HTTP assertions as easy as they come. Pass the `app` instance to `supertest` (usually aliased as `request`) and use expect-style assertions directly on the response. You can also pass in a callback to the `end` function for more in-depth testing.

### Rosie

We've created a lightweight [wrapper](test/factory_wrapper.coffeee) around [Rosie](https://github.com/bkeepers/rosie) to simplify creating test objects/fixtures. Feel free to use one of the fixtures that's already defined or else to extend the wrapper in accordance with the Rosie docs and API.
