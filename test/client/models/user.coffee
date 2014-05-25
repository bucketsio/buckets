User = require('../../../client/source/models/user')
{assert} = require('chai')

describe 'User', ->
  describe '#hello', ->
    it 'says hello to the user', ->
      u = new User(name: 'Johny')
      assert.equal(u.hello(), 'Hello Johny')
