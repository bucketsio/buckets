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
      publish:
        command: 'npm publish'

    concat:
      style:
        files:
          'public/css/buckets.css': [
            'public/fontastic/styles.css'
            'public/vendor/**/*.css'
            'public/css/bootstrap.css'
            'public/css/index.css'
          ]
      pluginsStyle:
        files:
          'public/css/plugins.css': ['public/plugins/*.css']

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
      fontastic:
        expand: yes
        cwd: 'client/assets/fontastic/fonts/'
        src: ['*']
        dest: 'public/css/fonts/'

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
          script: 'server/start.coffee'
          opts: ['node_modules/coffee-script/bin/coffee']

    less:
      app:
        expand: true,
        cwd: 'client/style'
        src: ['**/*.less']
        dest: 'public/css/'
        ext: '.css'

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
          'public/vendor/spin.js/spin.js': ['public/vendor/spin.js/spin.js']

      vendor:
        dest: 'public/js/vendor.js'
        src: [
          # Order matters for some
          'public/vendor/ladda/js/ladda.js'
          'public/vendor/ladda/js/ladda.jquery.js'

          'public/vendor/blueimp-file-upload/js/jquery.ui.widget.js'
          'public/vendor/blueimp-file-upload/js/jquery.fileupload.js'
          'public/vendor/cloudinary_js/js/jquery.cloudinary.js'

          'public/vendor/**/*.js'

          # Remove some which we’ll load on the fly
          '!public/vendor/spin.js/spin.js'
          '!public/vendor/fastclick/fastclick.js'
          '!public/vendor/jquery/**/*.js'
        ]
        filter: 'isFile'

      plugins:
        dest: 'public/js/plugins.js'
        src: ['public/plugins/*.js']

      options:
        sourceMap: yes
        screwIe8: yes
        mangle: yes

    watch:
      apidoc:
        files: ['server/routes/api/**/*.coffee']
        tasks: ['apidoc', 'copy:docs']

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
        files: ['server/**/*.coffee', 'node_modules/buckets-*/*.{coffee,hbs}', '.env']
        tasks: ['express:dev']
        options:
          spawn: false
          livereload: true

      pluginScripts:
        files: ['node_modules/buckets-*/**/{models,controllers,helpers,templates,views}/**/*.{coffee,hbs}', 'node_modules/buckets-*/*.{coffee,hbs}']
        tasks: ['browserify:plugins', 'uglify:plugins']

      pluginStyles:
        files: ['node_modules/buckets-*/**/*.styl']
        tasks: ['stylus:plugins', 'concat:plugins']

      livereload:
        options:
          livereload: true
          interrupt: true
        files: [
          'public/{css,js}/*.{css,js}'
          'public/plugins/**/*.{css,js}'
        ]

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
  grunt.loadNpmTasks 'grunt-shell'

  grunt.registerTask 'build-style', ['stylus', 'less', 'concat:style', 'concat:pluginsStyle']
  grunt.registerTask 'build-scripts', ['browserify:app']

  # Building
  grunt.registerTask 'default', ['clean:app', 'bower', 'apidoc', 'copy', 'uglify:vendor', 'browserify:plugins', 'uglify:plugins', 'build-scripts', 'build-style', 'modernizr']
  grunt.registerTask 'prepublish', ['clean:all', 'default', 'uglify:app', 'cssmin']
  grunt.registerTask 'publish', ['prepublish', 'shell:publish']

  # Serving
  grunt.registerTask 'start', ['express:dev', 'watch']
  grunt.registerTask 'dev', ['default', 'start']

  # Tests
  grunt.registerTask 'test:server', ['shell:mocha']
  grunt.registerTask 'test:server:cov', ['shell:cov']
  grunt.registerTask 'test:client', ['default', 'browserify:tests', 'testem:ci:basic']
  grunt.registerTask 'test:client:html', ['browserify:tests', 'testem:ci:html']
  grunt.registerTask 'test', ['clean:all', 'test:server', 'test:client']
