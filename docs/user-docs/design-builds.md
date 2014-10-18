# Builds

Design Builds allow web designers to easily manage their website’s design. By default, every site running on Buckets will come with a staging and a live build. This allows designers to stage comprehensive redesigns, gain stakeholder approval, and launch their designs with virtually no downtime. Additionally, archive builds are automatically generated every time a new design is pushed to staging or live.

## How Builds Work

By default, builds are stored in `buckets/builds/`. At startup, Buckets will grab the current "live" build from the database and unpack it there (if none exists, it will scaffold this Build from an internal skeleton). The live build is unpacked by extracting to a folder with the name of the build and creating a symlink to this build (this is so we can later switch the live build without downtime).

For staging builds, the startup process is slightly different. Buckets will first look for a `builds/staging/` directory and, if it exists, attempt to create a staging build out of it and save to the database. We avoid saving unnecessary duplicates of staging builds by creating and verifying an md5 each time a build is created.

The staging directory does not use a symlink and remains a directory so developers who prefer to deploy via Git or FTP can consistently and easily do so.

## BuildFiles

Buckets separately stores a concept of BuildFiles, which represent edits made to files in either live or staging builds. BuildFiles allow designers to make changes from within the Buckets UI and have those changes persist between app restarts (without creating a new Build for every edit). After the initial live and staging builds are prepared during startup, BuildFiles are then "applied" to each. Once a build is re-packaged (eg. when publishing the staging Build to live), the BuildFiles for that environment are cleared (since the file changes are packaged into the Build).

