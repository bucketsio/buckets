# Design

This doc covers how to "theme" Buckets, ie. create a group of templates and frontend assets (CSS, JS, images, etc.) which serve as your website’s design. There are several features included in Buckets to make this process easier.

### Design Builds

By default, Buckets will track and save versions of your theme as "design builds." These are saved directly in the database, which gives Buckets the ability to roll back to a previous design and stage design changes (which all admins can preview). Design builds can either be staging, live, or archived.

### Staging Build

If working locally, you can edit the files for your staging build at `./builds/staging`.

#### Temporary: Setting up a local preview URL

Currently, Buckets hosts the staging build on a subdomain. While this works well in a hosted environment, it requires an extra step when working locally. You will have to add a local URL which uses a pattern of "**staging.**something.something". On a Mac, you can do this by editing your /etc/hosts file, and adding something like:

```
127.0.0.1 buckets.dev
127.0.0.1 staging.buckets.dev
```

Then in your configuration, add `host: 'buckets.dev'`.

I aim to add a way to _only_ use the staging build when working locally soon (so the staging subdomain is not necessary).

### Live Build

When Buckets is started up, it will pull the live build from the database, if available. If not, it will create a default theme. Live builds are not meant to be edited locally (though changes from the admin panel are persistant) and are created via a symlink (for instant deployments).

[Read more](design-builds.md)

### Automatic Preprocessing

Buckets comes with [Harp.js](http://harpjs.com/) built in. Harp.js is an awesome static server with built-in preprocessing, which values logical convention over configuration. For example, to use CoffeeScript, you could create a file at `js/index.coffee` and, in your Handlebars template, reference it with `<script src="js/index.js">`. Harp.js comes with support for Jade, Markdown, EJS, CoffeeScript, Sass, LESS and Stylus. [Learn more about Harp.js](http://harpjs.com/docs/)

### Design Editor

The editor provided in the admin panel allows designers and developers to make changes to both the current staging and live builds.

Tip: Hitting Command+enter while editing a file will save it.
