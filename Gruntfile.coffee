module.exports = (grunt) ->

  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    bower:
      install:
        options:
          targetDir: 'public/vendor/'
          layout: 'byComponent'

    browserify:
      app:
        files:
          'public/js/buckets.js': ['client/source/**/*.{coffee,hbs}']
      options:
        browserifyOptions:
          fullPaths: false
          extensions: ['.coffee', '.hbs']
        transform: ['coffeeify', 'hbsfy']
        bundleOptions:
          debug: true
        alias: [
          './app/bower_components/backbone/backbone.js:backbone'
          './app/bower_components/jquery/dist/jquery.js:jquery'
          './app/bower_components/chaplin/chaplin.js:chaplin'
          './app/bower_components/underscore/underscore.js:underscore'
        ]

    copy:
      assets:
        expand: yes
        cwd: 'client/assets'
        src: ['*']
        dest: 'public/'

    cssmin:
      app:
        files:
          'public/css/buckets.css': ['public/css/**/*.css']

    express:
      dev:
        options:
          script: 'server/index.coffee'
      options:
        spawn: false
        opts: ['node_modules/coffeeify/node_modules/coffee-script/bin/coffee']

    modernizr:
      app:
        devFile: 'public/vendor/modernizr/modernizr.js'
        outputFile: 'public/js/modernizr.min.js'
        files: 
          src: ['public/js/buckets.{css,js}']

    stylus:
      app:
        expand: yes
        cwd: 'client/style/'
        src: ['**/*.styl']
        dest: 'public/css/'
        ext: '.css'

    uglify:
      app:
        files:
          'public/js/buckets.js': ['public/js/buckets.js']
        options:
          sourceMap: true

    watch:
      clientjs:
        files: ['client/**/*.coffee']
        tasks: ['build']

      assets:
        files: ['client/assets/**/*.*']
        tasks: ['copy:assets']

      style:
        files: ['client/style/**/*.styl']
        tasks: ['build-style']

      express:
        files: ['server/**/*.coffee']
        tasks: ['express:dev']
        options:
          spawn: false
          livereload: true

      livereload:
        options: livereload: true
        files: ['public/**/*']
      
  grunt.loadNpmTasks 'grunt-bower-task'
  grunt.loadNpmTasks 'grunt-browserify'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-cssmin'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-express-server'
  grunt.loadNpmTasks 'grunt-mocha'
  grunt.loadNpmTasks 'grunt-modernizr'

  grunt.registerTask 'build-style', ['stylus']

  grunt.registerTask 'default', ['build']
  grunt.registerTask 'build', ['copy', 'bower', 'browserify', 'build-style', 'modernizr']
  grunt.registerTask 'minify', ['build', 'uglify', 'cssmin']

  grunt.registerTask 'dev', ['build', 'express:dev', 'watch']

  # grunt.registerTask 'serve', ['minify', 'express:dev', 'watch'] # Find way to do without watch?