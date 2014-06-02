Buckets uses [MongoDB](http://www.mongodb.org) as it’s database.

On Mac OS X, you can quickly install with:

```brew install mongodb```

If you want to start MongoDB automatically with your Mac, you include an easy LaunchAgent:

```
  ln -sfv /usr/local/opt/mongodb/*.plist ~/Library/LaunchAgents
  launchctl load ~/Library/LaunchAgents/homebrew.mxcl.mongodb.plist
```

For Windows/Linux users, please just refer to MongoDB homepage and follow the installation instructions.
