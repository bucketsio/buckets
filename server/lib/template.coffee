glob = require 'glob'
fs = require 'fs'
path = require 'path'

module.exports = (cwd) ->

  unless cwd
    throw 'Must be passed a directory path.'

  resolve = (filename) -> path.join(cwd, path.resolve("/", filename))

  mkdirp = (directory, callback) ->
    fs.mkdir directory, (err) ->
      if err
        if err.code is "EEXIST"
          return callback()
        if err.code is "ENOENT"
          return mkdirp path.dirname(directory), (err) ->
            return mkdirp(directory, callback)
        return callback(err)
      callback()

  cleanup = (directory, callback) ->
    return callback() if directory.length <= cwd.length
    fs.readdir directory, (err, files) ->
      return callback(err) if err
      return callback() if files.length
      fs.rmdir directory, (err) ->
        return callback(err) if err
        cleanup path.dirname(directory), callback

  class Template

    find: (callback) ->
      # Return all Handlebars paths
      glob '**/*.hbs', {cwd: cwd}, (err, files) ->
        return callback(err) if err
        items = []
        left = files.length + 1
        done = false

        # Simple inline async helper
        check = (err) ->
          if err
            return if done
            done = true
            return callback err
          return if --left
          done = true
          callback null, items

        for filename, i in files
          do (filename, i) ->
            fs.readFile cwd + filename, 'utf8', (err, contents) ->
              if err
                check err
              else
                items[i] = {filename: filename.replace(/\.hbs$/,''), contents: contents}
                check()
        check()


    read: (filename, callback) ->
      fs.readFile resolve(filename + '.hbs'), 'utf8', callback

    write: (filename, contents, callback) ->
      filename = resolve(filename+'.hbs')
      mkdirp path.dirname(filename), (err) ->
        return callback(err) if err
        fs.writeFile(filename, contents, callback)

    remove: (filename, callback) ->
      filename = resolve(filename+'.hbs')
      fs.unlink filename, (err) ->
        return callback(err) if err
        cleanup path.dirname(filename), callback

  new Template
