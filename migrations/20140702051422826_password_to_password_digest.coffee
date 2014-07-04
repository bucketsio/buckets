User = require '../server/models/user'
async = require 'async'

module.exports =
  requiresDowntime: no

  up: (done) ->
    User.find {}, (err, users) ->

      # Batch ops to set passwordDigest
      ops = []
      for user, i in users
        if {password} = user.toObject()
          user.passwordDigest = password
          ops.push (next) ->
            user.save next

      async.parallel ops, (err) ->

        # Finally, nix old password field
        User.update {}, {$unset: password: yes}, {multi: yes, strict: no}, done

  down: (done) ->
    throw new Error('irreversible migration')
