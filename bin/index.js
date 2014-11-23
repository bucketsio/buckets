#!/usr/bin/env node

var buckets  = require('nomnom');
var log      = require('./utils/log');

/**
 * Define commands.
 */
buckets
  .script('buckets');

buckets
  .command('generate')
  .help('Generate a Buckets skeleton project.')
  .option('name', {
    position: 1,
    required: true,
    help: 'The name of your project.'
  });

buckets
  .command('serve')
  .help('Serve the local theme directory.')
  .option('port', {
    position: 1,
    required: false,
    help: 'The port to run on. Defaults to 3000.'
  });

buckets
  .command('repl')
  .help('Enter a Buckets REPL environment.');

// Eat the user inputs.
var opts = buckets.nom();

/**
 * Delegate commands.
 */
switch (opts[0]) {

  case 'generate':
    require('./commands/generate')(opts.name);
    break;

  case 'serve':
    require('./commands/serve')(opts.port);
    break;

  case 'repl':
    require('./commands/repl')();
    break;

}
