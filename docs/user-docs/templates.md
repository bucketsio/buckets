# User Templates

Buckets uses [hbs](https://github.com/donpark/hbs) (a version of [Handlebars](http://handlebarsjs.com) optimized for Express) as its template engine. Additionally, we load [Swag](https://github.com/elving/swag) by default, which provides a lot of convenient Helpers.

**Alpha Notice:** Buckets is in Alpha stage and some features listed below may not be implemented yet. [Help decide how templates shape up](https://assembly.com/buckets/projects/54).

## Special Templates

* **layout**.hbs: Will automatically wrap any other template that’s served. Useful for adding global header and footer elements to the page.
* **error**.hbs: Buckets will automatically attempt to render the error page if it encounters either a missing Route (404) or encounters an error (500). It’s recommended to not use the `entries` tag within the error template.

Both of these templates are included by default.

## Helpers

### Entries

Basic syntax:

```
{{#entries}}
  <h1>{{title}}</h1>
  {{#is author.email ‘dk@morfunk.com’}}
     By Dave
  {{else}}
     Guest Author
  {{/is}}
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
* **skip:** Combine this with the limit parameter to create pagination.
* **where:** Pass a string like, `where="year > 2013 && (price < 10 || onSale)"` using the custom attributes of your Bucket. **Note:** This has negative performance implications, though it provides a very powerful search mechanism. This is not implemented yet, though you can use it with a wacky format like, `where="this.content.year > 2013"`
* **since:** Only show entries that were published after the date provided.
* **until:** Only show entries that were published before the date provided.
* **sort:** Use a mongoose-style sort string, eg. `sort="-publishDate"`, `sort="lastName firstName"`

```
{{#entries limit=10 skip=req.query.next}}
  ...
{{/entries}}
```

### renderTime

Renders the time (in ms) the page has taken to render (best to place near the footer).

```
{{renderTime}}
```

### formatTime

Shows a formatted time using Moment.js. Check out [the docs](http://momentjs.com/docs/#/displaying/format/) to see what formats are available.

```
{{formatTime publishDate format="MMM D, YYYY h:mma"}}
```

### timeAgo

Shows the difference between the date given and now.

```
{{timeAgo "2014-01-01 00:00:00"}}
```

### next

Passes through to the next matching [Route](routes.md). Best used in conjunction with entries tag like so:

```
{{#entries}}
  <h1>{{title}}</h1>
  …
{{else}}
  {{next}}
{{/entries}}
```

_Note: All of these parameters are also supported by the [Buckets REST API](api/)._

### munge

Good for hiding email addresses from spammers.

```
Contact us at {{munge 'support@buckets.io'}}
```

### inspect

Pretty-prints an object for debugging. Automatically HTML-encodes values.

```
{{inspect req}}
```

## Global variables

Basic global object passed to every Template:


### req

An object of data about the current page request.

### req.body

The `body` object of data from POST requests (values received when forms are submitted).

```
<form method="POST">
  <input type="text" name="foo">
  {{#if req.body}}
    You submitted {{req.body.foo}}
  {{/if}}
</form>
```

### req.path

The current request URL.

### req.query

An object of query parameters (id. "?foo=bar" on the URL).

```
<a href="/?clicked=true">Click Me</a>
{{#if req.query.clicked}}
  You clicked it!
{{/if}}
```

### req.params

An object of parameters passed through [the Route’s URL](routes.md)

```
<a href="/?clicked=true">Click Me</a>
{{#if req.query.clicked}}
  You clicked it!
{{/if}}
```

### adminSegment

The slug of your Buckets admin.

```
<a href="/{{adminSegment}}/">Sign In</a>
```

### user

An object of data about the current Buckets user.

```
You are currently logged in as {{user.name}}
```

## Partials

TODO
