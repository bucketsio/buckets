glob = require 'glob'
fs = require 'fs'
path = require 'path'
DbTemplate = require('../models/template')

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

    find: (callback) =>
      # Return all Handlebars paths
      glob '**/*.hbs', {cwd: cwd}, (err, files) =>
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
          do (filename, i) =>
            f = filename.replace(/\.hbs$/,'')
            @read(f, (err, contents) ->
              if err
                return check(err)
              items[i] = { filename: f, contents: contents }
              check()
            )
        check()

    read: (filename, callback) ->
      filename = resolve(filename)
      fs.readFile(filename + '.hbs', 'utf8', (err, contents) ->
        if err
          if err.code == 'ENOENT'
            DbTemplate.findOne({ filename: filename }, (dbErr, template) ->
              if dbErr
                return callback(dbErr)
              if not template
                return callback(err)
              callback(null, template.contents)
            )
          else
            callback(err)
        else
          callback(null, contents)
      )

    write: (filename, contents, callback) ->
      if filename instanceof Array
        newName = resolve(filename[1] + '.hbs')
        filename = filename[0]

      filename = resolve(filename + '.hbs')
      dir = path.dirname(filename)

      save = (doc, cb) ->
        DbTemplate.findOne { filename: filename }, (err, template) ->
          return cb(err) if err

          if not template
            template = new DbTemplate(doc)
          else
            for k, v of doc
              template[k] = v

          template.save((err, t) ->
            return cb(err) if err
            cb()
          )

      mkdirp dir, (err) ->
        return callback(err) if err
        doc =
          filename: filename,
          contents: contents,
          directory: dir

        if newName
          doc.filename = newName

        save(doc, (err) ->
          return callback(err) if err
          fs.writeFile(filename, contents, (err) ->
            return callback(err) if err

            if newName
              DbTemplate.renameRoutes(filename, newName, (err) ->
                return callback(err) if err
                fs.rename(filename, newName, callback)
              )
            else
              callback()
          )
        )

    remove: (filename, callback) ->
      filenameExt = resolve(filename+'.hbs')
      dir = path.dirname(filenameExt)

      DbTemplate.remove { filename: filenameExt }, (err) ->
        return callback(err) if err
        fs.unlink filenameExt, (err) ->
          return callback(err) if err
          cleanup path.dirname(filenameExt), callback

  new Template
