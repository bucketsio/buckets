Buckets uses [RethinkDB](http://rethinkdb.com/) as it’s database.

On Mac OS X, you can quickly install with:

```brew install rethinkdb```

If you want to start RethinkDB automatically with your Mac, you include an easy LaunchAgent:

```
  ln -sfv /usr/local/opt/rethinkdb/*.plist ~/Library/LaunchAgents
  launchctl load ~/Library/LaunchAgents/homebrew.mxcl.rethinkdb.plist
```

For Windows/Linux users, please just refer to RethinkDB homepage and follow the installation instructions.