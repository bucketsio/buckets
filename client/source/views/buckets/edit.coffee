PageView = require 'views/base/page'

tpl = require 'templates/buckets/edit'

module.exports = class BucketEditView extends PageView
  template: tpl
  autoRender: yes