fs = require 'fs'

module.exports =
  loadClasses: (path) ->
    classes = []
    fs.readdirSync(path).forEach (file) ->
      try
        if file.match(/\.(js|coffee)$/)
          c = require path + file
          classes.push c
      catch e
        console.log 'Error loading the class', file, e
    classes
