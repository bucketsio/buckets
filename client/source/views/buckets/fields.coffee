_ = require 'underscore'

PageView = require 'views/base/page'
FormMixin = require 'views/base/mixins/form'

tpl = require 'templates/buckets/fields'

module.exports = class BucketFieldsView extends PageView
  @mixin FormMixin

  template: tpl
  getTemplateData: ->
    _.extend super,
      fieldTypes: [
        name: 'Text', value: 'text'
      ,
        name: 'HTML Editor', value: 'html'
      ,
        name: 'Number', value: 'number'
      ,
        name: 'Checkbox', value: 'checkbox'
      ,
        name: 'Date/time', value: 'datetime'
      ,
        name: 'Email', value: 'email'
      ,
        name: 'File', value: 'file'
      ,
        name: 'Relationship', value: 'relationship'
      ,
        name: 'Color', value: 'color'
      ,
        name: 'Location', value: 'location'
      ]
