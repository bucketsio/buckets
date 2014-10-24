_ = require 'underscore'

Collection = require 'lib/collection'
BuildFile = require 'models/buildfile'

module.exports = class Templates extends Collection
  build_env: 'staging'
  url: ->
    console.log 'fetching group', @build_env
    "/api/buildfiles/#{@build_env}/"
  model: BuildFile
  comparator: 'filename'
  getTree: ->
    # Converts list of paths (eg. from glob), to a tree structure
    tree = {}

    _.map @toJSON(), (obj) ->
      parts = obj.filename.replace(/^\/|\/$/g, "").split('/')
      ptr = tree
      pathId = ""
      path = ""
      for part, i in parts
        node =
          name: part
          type: 'directory'
          pathId: pathId += "_#{part}".replace /[^A-Za-z0-9 \-\_]/, '-'
          path: path += part + "/"

        if i is parts.length - 1 and not obj.filename.match /\/$/
          node.type = 'file'
          node.path = obj.filename

        ptr[part] = ptr[part] || node
        ptr[part].children = ptr[part].children || {}
        ptr = ptr[part].children

    tree
