Buckets is deployed to [buckets.io](http://buckets.io) on Heroku.

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
