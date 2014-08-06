Buckets is currently deployed to [playground.buckets.io](http://playground.buckets.io) on Heroku.

To get added to the project ask the Core Team for access.

Once you have access, run this command to get setup:

```
git remote add heroku git@heroku.com:asm-buckets.git
```

Now you can run the following command whenever you want to deploy the master branch:

```
git push heroku master
```

This will compile all of the assets and boot the express app.

If you ever want to try out a new feature before merging it you can deploy a branch with the following command where `new-feature-branch` is the branch name:

```
git push heroku new-feature-branch:master
```

### NPM Cache Reset

Occassionally it may be required to clear NPM's cache. Unfortunately, [the buildpack we currently use](https://github.com/mbuchetics/heroku-buildpack-nodejs-grunt) does not provide any means to do this, though there [is a fix being proposed upstream](https://github.com/heroku/heroku-buildpack-nodejs/pull/103) with Heroku's Node buildpack.

While it works, it means switching buildpacks and a few extraneous pushes:


```
cd buckets

# Clear the cache
heroku config:set BUILDPACK_URL=https://github.com/heroku/heroku-buildpack-nodejs#no-cache-option
touch .no-cache
git add .no-cache
git commit -m "add .no-cache file"
git push heroku master

# Reset the buildpack
heroku config:set BUILDPACK_URL=https://github.com/mbuchetics/heroku-buildpack-nodejs-grunt.git
rm .no-cache
git rm .no-cache
git commit -m "nix .no-cache file"
git push heroku master
```
