config = require './server/config'
mongoose = require 'mongoose'

module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    apidoc:
      app:
        src: 'server/routes/api/'
        dest: 'docs/api/'
        marked:
          gfm: yes

    bower:
      install:
        options:
          targetDir: 'public/vendor/'
          layout: 'byComponent'
          cleanTargetDir: yes

    browserify:
      options:
        transform: ['coffeeify', 'hbsfy']
        # bundleOptions:
        #   debug: yes
        browserifyOptions:
          fullPaths: true
          extensions: ['.coffee', '.hbs']
          paths: ['./client/source', 'node_modules']
          detectGlobals: no # Disable "detect-globals" for faster build
          noParse: [
            'bower_components/backbone/backbone.js'
            'bower_components/chaplin/chaplin.js'
            'bower_components/cocktail/Cocktail.js'
            'bower_components/underscore/underscore.js'
          ]
        alias: [
          'bower_components/backbone/backbone.js:backbone'
          'bower_components/chaplin/chaplin.js:chaplin'
          'bower_components/cocktail/Cocktail.js:cocktail'
          'bower_components/underscore/underscore.js:underscore'
          'hbsfy/runtime:hbsfy/runtime'
          'client/source/buckets.coffee:buckets'
        ]
      app:
        files:
          'public/js/buckets.js': [
            'client/source/**/*.{coffee,hbs}'
          ]

      tests:
        files:
          'tmp/tests.js': ['test/client/**/*.coffee']

      plugins:
        options:
          external: ['buckets', 'hbsfy/runtime']
          alias: []
        files: [
          expand: yes
          cwd: 'node_modules/'
          src: ['buckets-*/client.coffee']
          dest: 'public/plugins/'

          # We compress all plugins down to one file
          # This file can be loaded/re-loaded on demand
          rename: (dest, path, options) ->
            pluginName = path.split('/')[0]?.replace('buckets-', '')
            dest + pluginName + '.js' if pluginName
        ]

    clean:
      app: ['public']
      all: ['public', 'bower_components', 'tmp']

    testem:
      basic:
        options:
          parallel: 2
          framework: 'mocha'
          src_files: ['tmp/tests.js']
          serve_files: ['tmp/tests.js']
          launch_in_dev: ['phantomjs', 'chrome']
          launch_in_ci: ['phantomjs', 'chrome']
      html:
        options:
          framework: 'mocha',
          serve_files: 'tmp/tests.js'
          test_page: 'test/client/tests.mustache'

    shell:
      mocha:
        command: 'NODE_ENV=test ./node_modules/mocha/bin/mocha --compilers coffee:coffee-script/register --recursive test/server -b'
      cov:
        command: 'NODE_ENV=test ./node_modules/mocha/bin/mocha --compilers coffee:coffee-script/register --recursive test/server --require blanket --reporter html-cov > coverage.html'
      npm_install:
        command: 'npm install'

    concat:
      style:
        files:
          'public/css/buckets.css': [
            'public/fontastic/styles.css'
            'public/vendor/**/*.css'
            'public/css/bootstrap.css'
            'public/css/index.css'
          ]

    copy:
      assets:
        expand: yes
        cwd: 'client/assets'
        src: ['**/*']
        dest: 'public/'
      docs:
        expand: yes
        cwd: 'docs/api'
        src: ['**/*']
        dest: 'public/docs/api'
      fontastic:
        expand: yes
        cwd: 'client/assets/fontastic/fonts/'
        src: ['*']
        dest: 'public/css/fonts/'
      ace:
        expand: yes
        cwd: 'bower_components/ace-builds/src-min-noconflict/'
        src: [
          'ace.js'
          'mode-handlebars.js'
          'worker-handlebars.js'
          'theme-*.js' # These are loaded on the fly anyway
        ]
        dest: 'public/js/ace/'

    cssmin:
      app:
        files:
          'public/css/buckets.css': [
            'public/css/buckets.css'
          ]

    express:
      dev:
        options:
          spawn: false
      prod:
        options:
          background: false
          livereload: false
      server:
        options:
          background: false
      options:
        port: process.env.PORT or 3000
        script: 'server/index.coffee'
        opts: ['node_modules/coffee-script/bin/coffee']

    less:
      app:
        expand: true,
        cwd: 'client/style'
        src: ['**/*.less']
        dest: 'public/css/'
        ext: '.css'

    migrations:
      path: "#{__dirname}/migrations"
      mongo: config.db

    modernizr:
      app:
        devFile: 'bower_components/modernizr/modernizr.js'
        outputFile: 'public/js/modernizr.min.js'
        files:
          src: ['public/js/buckets.{css,js}']

    stylus:
      app:
        expand: yes
        cwd: 'client/style/'
        src: ['**/*.styl', '!_*.styl']
        dest: 'public/css/'
        ext: '.css'

      plugins:
        expand: yes
        cwd: 'node_modules/'
        src: ['buckets-*/**/*.styl', '!_*.styl']
        dest: 'public/plugins/'

        # We compress all plugins down to one file
        # This file can be loaded/re-loaded on demand
        rename: (dest, path, options) ->
          pluginName = path.split('/')[0]?.replace('buckets-', '')
          dest + pluginName + '.css' if pluginName

    uglify:
      app:
        files:
          'public/js/buckets.js': ['public/js/buckets.js']

      vendor:
        dest: 'public/js/vendor.js'
        src: [
          # Order matters for some
          'public/vendor/spin.js/spin.js'
          'public/vendor/ladda/js/ladda.js'
          'public/vendor/ladda/js/ladda.jquery.js'

          'public/vendor/**/*.js'

          # Remove some which we’ll load on the fly
          '!public/vendor/fastclick/fastclick.js'
          '!public/vendor/jquery/**/*.js'
        ]
        filter: 'isFile'

      options:
        sourceMap: yes
        screwIe8: yes
        mangle: yes

    watch:
      apidoc:
        files: ['server/routes/api/**/*.coffee']
        tasks: ['apidoc']

      bower:
        files: ['bower.json']
        tasks: ['bower', 'uglify:vendor', 'browserify']

      clientjs:
        files: [
          'client/**/*.{coffee,hbs}'
        ]
        tasks: ['browserify:app']
        options:
          interrupt: yes

      clientTest:
        files: ['test/client/**/*.coffee']
        tasks: ['test:client']

      serverTest:
        files: ['test/server/**/*.coffee']
        tasks: ['shell:mocha']
        options:
          interrupt: yes

      assets:
        files: ['client/assets/**/*.*']
        tasks: ['copy']

      style:
        files: ['client/style/**/*.{styl,less}']
        tasks: ['build-style']

      express:
        files: ['server/**/*.coffee', 'node_modules/buckets-*/*.{coffee,hbs}']
        tasks: ['express:dev']
        options:
          spawn: false
          livereload: true

      pluginScripts:
        files: ['node_modules/buckets-*/**/{models,controllers,helpers,templates,views}/**/*.{coffee,hbs}', 'node_modules/buckets-*/*.{coffee,hbs}']
        tasks: ['browserify:plugins']

      pluginStyles:
        files: ['node_modules/buckets-*/**/*.styl']
        tasks: ['stylus:plugins']

      livereload:
        options:
          livereload: true
        files: [
          'public/css/buckets.css'
          'public/js/{buckets,vendor}.css'
          'public/plugins/**/*.{css,js}'
        ]

  grunt.registerTask 'checkDatabase', (next, stuff...)->
    connection = mongoose.createConnection config.db, (err) ->
      if err
        throw "\nBuckets could not connect to MongoDB :/\n".magenta + "See the " + 'README.md'.bold + " for more info on installing MongoDB and check your settings at " + 'server/config.coffee'.bold + "."
        exit

  grunt.loadNpmTasks 'grunt-apidoc'
  grunt.loadNpmTasks 'grunt-bower-task'
  grunt.loadNpmTasks 'grunt-browserify'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-cssmin'
  grunt.loadNpmTasks 'grunt-contrib-less'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-testem'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-express-server'
  grunt.loadNpmTasks 'grunt-modernizr'
  grunt.loadNpmTasks 'grunt-mongo-migrations'
  grunt.loadNpmTasks 'grunt-shell'

  grunt.registerTask 'build-style', ['stylus', 'less', 'concat:style']
  grunt.registerTask 'build-scripts', ['browserify:app']

  grunt.registerTask 'default', ['build']
  grunt.registerTask 'build', ['clean:app', 'bower', 'apidoc', 'copy', 'uglify:vendor', 'browserify:plugins', 'build-scripts', 'build-style', 'modernizr']
  grunt.registerTask 'minify', ['build', 'uglify:app', 'cssmin']

  grunt.registerTask 'dev', ['shell:npm_install', 'checkDatabase', 'migrate:all', 'build', 'express:dev', 'watch']
  grunt.registerTask 'devserve', ['checkDatabase', 'migrate:all', 'express:dev', 'watch']
  grunt.registerTask 'serve', ['shell:npm_install', 'checkDatabase', 'migrate:all', 'minify', 'express:server']

  grunt.registerTask 'test:server', ['shell:mocha']
  grunt.registerTask 'test:server:cov', ['shell:cov']
  grunt.registerTask 'test:client', ['build', 'browserify:tests', 'testem:ci:basic']
  grunt.registerTask 'test:client:html', ['browserify:tests', 'testem:ci:html']
  grunt.registerTask 'test', ['clean:all', 'test:server', 'test:client']

  grunt.registerTask 'heroku:production', ['minify', 'migrate:all']
