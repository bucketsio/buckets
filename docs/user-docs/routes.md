# Routes

Routes map [Express-style URL Patterns](https://github.com/pillarjs/path-to-regexp) to [Templates](./templates.md). A few features of URL patterns:

## Parameters

The path has the ability to define parameters which populate `{{req.params}}` in the rendered Template. For example, a Route which uses the URL pattern, _`/entries/:slug`_, would pass a `slug` value to its Template:

```(handlebars)
{{#entries limit="1" slug=req.params.slug}}
  <h1>{{title}}</h1>
{{/entries}}
```

### Suffixed Parameters

* _`/:foo?`_ **Optional**
* _`/:foo*`_ **Zero or more**
* _`/:foo+`_ **One or more**
* _`/:foo(\\d+)`_ **Regex support** (Backslashes need to be escaped)

You can try testing Routes and parameters with the [Express Route Tester](http://forbeslindesay.github.io/express-route-tester/).

## Ordering and `{{next}}`

The order of your Routes matter. Every time a user hits a page on your site, the URI (eg. /news/2014/) will attempt to match against each of your Routes, from the top of the list to the bottom.

Once a hit is made, Buckets will attempt to render its [Template](./templates.md). If there is an error—or if the Template calls the `{{next}}` tag—the current Route gets put aside and we keep going down the list.

This makes it easy to provide complex URL schemes by creating multiple Routes like "/news/:year" and "/news/:slug", and use two separate Templates for them, depending on if a match is made.

## Feature Planning

[View the planning for Routes on Assembly.](https://assembly.com/buckets/projects/89)
