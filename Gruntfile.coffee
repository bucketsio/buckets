config = require './server/config'
mongoose = require 'mongoose'

module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    bower:
      install:
        options:
          targetDir: 'public/vendor/'
          layout: 'byComponent'
          cleanTargetDir: yes

    browserify:
      options:
        transform: ['coffeeify', 'hbsfy']
        bundleOptions:
          debug: yes
        browserifyOptions:
          fullPaths: true
          basedir: './client/source/'
          commondir: "#{__dirname}/client/source/"
          extensions: ['.coffee', '.hbs']
          paths: ['./client/source', 'node_modules']
          detectGlobals: no # Disable "detect-globals" for faster build
          noParse: [
            './bower_components/backbone/backbone.js'
            './bower_components/chaplin/chaplin.js'
            './bower_components/cocktail/Cocktail.js'
            './bower_components/underscore/underscore.js'
          ]
        alias: [
          './bower_components/backbone/backbone.js:backbone'
          './bower_components/chaplin/chaplin.js:chaplin'
          './bower_components/cocktail/Cocktail.js:cocktail'
          './bower_components/underscore/underscore.js:underscore'
        ]
      app:
        files:
          'public/js/buckets.js': ['client/source/**/*.{coffee,hbs}']
      tests:
        files:
          'tmp/tests.js': ['test/client/**/*.coffee']

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
        command: 'NODE_ENV=test ./node_modules/mocha/bin/mocha --compilers coffee:coffee-script/register --recursive test/server'
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
        ]
        filter: 'isFile'

      options:
        sourceMap: true
        screwIe8: yes
        mangle: yes

    watch:
      bower:
        files: ['bower.json']
        tasks: ['bower']

      clientjs:
        files: ['client/**/*.{coffee,hbs}']
        tasks: ['browserify:app']

      clientTest:
        files: ['test/client/**/*.coffee']
        tasks: ['test:client']

      serverTest:
        files: ['test/server/**/*.coffee']
        tasks: ['shell:mocha']

      vendor:
        files: ['bower_components/**/*.{js,css}']
        tasks: ['bower', 'uglify:vendor', 'browserify']

      assets:
        files: ['client/assets/**/*.*']
        tasks: ['copy']

      style:
        files: ['client/style/**/*.{styl,less}']
        tasks: ['build-style']

      express:
        files: ['server/**/*.coffee']
        tasks: ['express:dev']
        options:
          spawn: false
          livereload: true

      livereload:
        options:
          livereload: true
        files: ['public/**/*']

  grunt.registerTask 'checkDatabase', (next, stuff...)->
    connection = mongoose.createConnection config.db, (err) ->
      if err
        throw "\nBuckets could not connect to MongoDB :/\n".magenta + "See the " + 'README.md'.bold + " for more info on installing MongoDB and check your settings at " + 'server/config.coffee'.bold + "."
        exit

  grunt.loadNpmTasks 'grunt-bower-task'
  grunt.loadNpmTasks 'grunt-browserify'
  grunt.loadNpmTasks 'grunt-coffeelint'
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
  grunt.registerTask 'build', ['clean:app', 'bower', 'copy', 'uglify:vendor', 'build-scripts', 'build-style', 'modernizr']
  grunt.registerTask 'minify', ['build', 'uglify:app', 'cssmin']

  grunt.registerTask 'dev', ['shell:npm_install', 'checkDatabase', 'migrate:all', 'express:dev', 'build', 'watch']
  grunt.registerTask 'devserve', ['checkDatabase', 'migrate:all', 'express:dev', 'watch']
  grunt.registerTask 'serve', ['shell:npm_install', 'checkDatabase', 'migrate:all', 'minify', 'express:server']

  grunt.registerTask 'test:server', ['build', 'shell:mocha']
  grunt.registerTask 'test:server:cov', ['build', 'shell:cov']
  grunt.registerTask 'test:client', ['browserify:tests', 'testem:ci:basic']
  grunt.registerTask 'test:client:html', ['browserify:tests', 'testem:ci:html']
  grunt.registerTask 'test', ['clean:all', 'test:server', 'test:client']

  grunt.registerTask 'heroku:production', ['minify']
