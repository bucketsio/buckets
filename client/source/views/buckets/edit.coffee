_ = require 'underscore'

PageView = require 'views/base/page'
BucketFieldsView = require 'views/buckets/fields'
FormMixin = require 'views/base/mixins/form'
tpl = require 'templates/buckets/edit'

module.exports = class BucketEditView extends PageView

  template: tpl

  optionNames: PageView::optionNames.concat ['fields']

  events:
    'submit form': 'submitForm'
    'click .swatches div': 'selectSwatch'
    'click [href="#delete"]': 'clickDelete'

  render: ->
    super
    @subview 'bucketFields', new BucketFieldsView
      collection: @fields
      container: @$('#fields')

  submitForm: (e) ->
    e.preventDefault()
    data = @formParams()

    data.color = @$('.colors div.selected').data('value')
    data.icon = @$('.icons div.selected').data('value')
    data.fields = @fields.toJSON()

    @submit @model.save(data, wait: yes)

  selectSwatch: (e) ->
    e.preventDefault()
    $el = @$(e.currentTarget)
    $el.addClass('selected').siblings().removeClass 'selected'

  clickDelete: (e) ->
    e.preventDefault()
    if confirm 'Are you sure?'
      @model.destroy wait: yes

  @mixin FormMixin
