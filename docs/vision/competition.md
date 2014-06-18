## What is Buckets’ competition?

When considering content management systems focussed on web publishing, there are (clearly) a plethora of existing options. I’ll attempt to categorize them and explain what Buckets seeks to improve:

### Open Source Content Management Systems

This is clearly the broadest market, with a variety of options like [Wordpress](http://wordpress.org), [ExpressionEngine](http://ellislab.com/expressionengine), [Textpattern](http://textpattern.com), [Drupal](https://drupal.org), [Ghost](https://ghost.org).

On the plus side, these systems are robust, have fantastic communities (and plugins) and are open source. On the negative side, most of these systems are bloated with features/controls, are geared only toward web publishing (and often just blogging out of the box), and are generally not designed for simple, delightful interactions (compared to apps like Tumblr and Squarespace for example, Ghost is the breakout here).

Additionally, many of these systems are created in PHP/MySQL, and don't make use of a modern web and dependency stack. Buckets is built with the most modern Javascript, something every web developer should be familiar with, and is a pleasure to code in.


### Static Site Generators and Flat File Systems

[Kirby](http://getkirby.com), [Statamic](http://statamic.com), and even [Octopress](http://octopress.org) are some cool contenders here, but barely worth mentioning as they require technical expertise, have limited search functionality, and generally don’t do dynamic content/templates well.

### Social Services and SaaS apps

Apps like [Tumblr](http://www.tumblr.com), [Squarespace](http://squarespace.com), [Virb](http://virb.com) all have fantastic user interfaces, but generally offer limited, pre-determined data structures and URL patterns. Additionally, by being closed source, these are not contenders for large organizational websites or internal tools. In fact, these are likely not competitors at all, I mention them mostly to describe the level of UI polish that we are striving for.

### Database Tools

In the direct context of “content management”, a true mark of success would be if Buckets could replace traditional, user-friendly, database tools, such as [Filemaker Pro](http://www.filemaker.com). As an extension of this, Buckets should eventually be adaptable to allow an organization to create its own tools: whether a CRM, billing/timesheet manager, or GTD app (things like this could eventually be commercial modules on top of Buckets as well).

Additionally, for Node.js and Mongo developers, there is a significant lack of administrative tools. In this way, Buckets could for Node.js what the Django Admin is for Python.