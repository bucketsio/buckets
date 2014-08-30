User = require '../server/models/user'
bcrypt = require 'bcrypt'
async = require 'async'

module.exports =
  requiresDowntime: no

  up: (done) ->
    User.find {}, 'password', (err, users) ->

      # Batch ops to set passwordDigest
      ops = []
      for user, i in users
        if {password} = user.toObject()
          next('Already migrated') if user.passwordDigest
          user.passwordDigest = bcrypt.hashSync(password, bcrypt.genSaltSync())

          ops.push (next) ->
            user.save next
        else
          next('Couldn’t get the user’s password.')

      async.parallel ops, (err) ->
        throw err if err

        # Finally, nix old password field
        User.update {}, {$unset: password: yes}, {multi: yes, strict: no}, done

  down: (done) ->
    throw new Error('irreversible migration')
