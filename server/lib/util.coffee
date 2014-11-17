fs = require 'fs'
util = require 'util'


# recurse through object/array looking for keys starting with '$' like {'$gt': '<any>'}
# returns the offending object if it finds any bad keys
# otherwise returns false
checkKeys = (firstObj) ->
  # should return on strings, functions, numbers, etc
  
  doCheck = (obj) ->
    return unless typeof obj == 'object'

    if util.isArray obj
      doCheck elem for elem in obj
    else if obj instanceof Object
      for key, value of obj
        if /^\$/.test(key) then throw obj
        if typeof value == 'object' then doCheck value

    return # otherwise above loops collect results

  try
    doCheck(firstObj)
  catch errorObj
    return errorObj

  return false

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

  checkForDollarKeys: checkKeys


