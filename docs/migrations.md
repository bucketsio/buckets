# Migrations

Migrations are used for any development updates that need to change the expected structure of the database.

To handle migrations, we're currently using a grunt plugin, [grunt-mongo-migrations](https://github.com/goodeggs/grunt-mongo-migrations) (this may change if we [switch to Gulp](https://assembly.com/buckets/wips/178)). To generate a new migration, simply run `grunt migrate:generate`. To run pending migrations use `grunt migrate:all`

Note that migrations are automatically run with `grunt dev` and `grunt heroku:production`.
