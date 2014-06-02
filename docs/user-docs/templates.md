# User Templates

**Alpha Notice** Please note that Buckets is in Alpha stage and some features listed below may not be functional.

This document describes the functionality available in the user-facing templates in Buckets.

## Basic

Buckets uses [Handlebars](http://handlebarsjs.com) as its template engine. Additionally, we load [Swag](https://github.com/elving/swag) which provides a lot of nice Helpers.

## Helpers

### Entries

```
{{#entries}}
  <h1>{{title}}</h1>
  {{description}}
{{else}}
  <div class="warn">Sorry, no entries available yet.</div>
{{/entries}}
```

#### Parameters

Parameters can be added to the tag like so:

```
{{#entries limit=3 bucket="products"}}
  ...
{{/entries}}
```

* **bucket:** Pass the slug of a Bucket to filter entries. Pass multiple Buckets with a pipeline separator, eg. `bucket="products|articles"`.
* **limit:** Limit the number of entries returned.
* **where:** Pass a string like, `where="year > 2013 && (price < 10 || onSale)"` using the custom attributes of your Bucket. Note: This has negative performance implications, though it provides a very powerful search mechanism.
* **since:** Only show entries that were published after the date provided.
* **until:** Only show entries that were published before the date provided.
* **skip:** Combine this with the limit parameter to create pagination.

```
{{#entries limit=10 skip=req.query.next}}
  ...
{{/entries}}
```

### renderTime

```
{{renderTime}}
```

Simply renders the time (in ms) the page has taken to load.
