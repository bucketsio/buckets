{expect} = require 'chai'

serverPath = '../../../server'
util = require "#{serverPath}/lib/util"


describe 'lib/util', ->
  describe 'checkForDollarKeys', () ->

    it 'catches basic object with a key of `$gt`', () ->
      testData = {
        'hello': ['hi','how are you?','good day'],
        '$gt': ''
        '[$gt]': 5
      }
      badObject = util.checkForDollarKeys testData
      expect(badObject).to.equal testData

    it 'catches a bad key in an object inside an array', () ->
      testData = {
        'hello': {
          'again': ['hi','how are you?','good day', {'$lt': 'dogs'}],
        },
        '$gt': ''
      }
      badObject = util.checkForDollarKeys testData
      expect(badObject).to.deep.equal({'$lt': 'dogs'})

    it 'catches a bad key in a top level array', () ->
      testData = ['cat',{'$eq': 'dog'}]
      badObject = util.checkForDollarKeys testData
      expect(badObject).to.deep.equal({'$eq': 'dog'})

    it 'catches a deeply nested object', () ->
      testData = {
        'one': 'hi',
        'two': {
          'hello': {
            '$gt': ''
          }
        }
      }
      badObject = util.checkForDollarKeys testData
      expect(badObject).to.deep.equal({'$gt': ''})