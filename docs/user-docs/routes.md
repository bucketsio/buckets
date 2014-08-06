# Routes

**Alpha Notice** Please note that Buckets is in Alpha stage and some features listed below may not be implemented yet. [Help decide how routes shape up](https://assembly.com/buckets/projects/89).

## Introduction

Buckets allows users to define “Routes” for their frontend URLs. Each Route maps to a [Template](./templates.md). Under the hood, Routes leverage Express.js to parse the URL pattern into a Regex which is then matched when a new request comes in.

A quick primer on Route patterns:

* **/entries/:var** Matches /entries/123 but not /entries/
* **/entries/:var?** Matches both /entries/123 and /entries/ (param is optional)
* **/entries/*** Matches /entries/123, /entries/, and /entries/123/456 (catch all)

There are many more options available, like regex-style matching, one-or-more matching, etc. For a full list of the types of paths you can pass, refer to the [path-to-regexp](https://github.com/component/path-to-regexp/commits/master) documentation—or try testing patterns with the [Express Route Tester](http://forbeslindesay.github.io/express-route-tester/).

## Sorting Routes and Passing Through

Buckets approximates Express.js’s system of middleware by allowing the website creator to use a `{{next}}` tag within Templates. This tag will immediately stop rendering the current template and “pass through” to the next template match. Similarly, a route will be passed through if the server experiences an error rendering the template. Here’s one example of using the same Route for two different templates:

Let’s say our sample website has a Bucket for TV Shows. The website designer may want to show a listing of TV shows if the user is looking at a cable network (like HBO), but show a detail page if viewing a specific show. They may want to expose these two pages through a similar URL, so /shows/HBO and /shows/true-detective show two different templates. To do this, they could simple create two different Routes which match on the same pattern:

* /shows/:network -> “network” template
* /shows/:slug -> “show” template

Within the “network” template, the website creator would look up Entries like so:

```(handlebars)
{{#entries network=req.params.network}}
	<h1>{{title}}</h1>
	…
{{else}}
	{{next}}
{{/entries}}
```

This would look for any entries where the `network` field matches the one passed into the URL. If no matches are found, however, the `{{next}}` tag will pass through to the “show” template.

**Note** The code above is not fully accurate in that we don’t (yet) have a manner to filter entries on custom fields. This will be implemented soon.
