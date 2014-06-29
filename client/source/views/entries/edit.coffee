_ = require 'underscore'

Model = require 'lib/model'
PageView = require 'views/base/page'
FormMixin = require 'views/base/mixins/form'
FieldTypeInputView = require 'views/fields/input'

tpl = require 'templates/entries/edit'

mediator = require 'mediator'

module.exports = class EntryEditView extends PageView
  className: 'EntryEditView'
  template: tpl
  optionNames: PageView::optionNames.concat ['bucket', 'user']

  regions:
    'user-fields': '.userFields'

  events:
    'submit form': 'submitForm'
    'click [href="#delete"]': 'clickDelete'
    'click [href="#draft"]': 'clickDraft'

  getTemplateData: ->
    fields = @bucket.get('fields')
    _.map fields, (field) =>
      field.value = @model.get(field.slug)
      field

    _.extend super,
      bucket: @bucket.toJSON()
      user: @user?.toJSON()
      fields: fields
      newTitle: "New #{@bucket.get('singular')}"

  render: ->
    super
    content = @model.get('content')
    for field in @bucket.get('fields')
      fieldValue = content[field.slug]
      fieldModel = new Model _.extend field,
        value: fieldValue

      if field.fieldType in ['text', 'textarea', 'color', 'checkbox', 'number']
        @subview 'field_'+field.slug, new FieldTypeInputView
          model: fieldModel
        continue

      mediator.loadPlugin(field.fieldType).done =>
        plugin = mediator.plugins[field.fieldType]

        if plugin?
          if _.isFunction plugin.input
            @subview 'field_'+field.slug, new plugin.input
              model: fieldModel
              region: 'user-fields'

          else if _.isString plugin.input
            @subview 'field_'+field.slug, new FieldTypeInputView
              template: plugin.input
              model: fieldModel

    TweenLite.from @$('.panel'), .5,
      scale: .7
      opacity: 0
      y: 100
      ease: Elastic.easeInOut
      easeParams: [.4, 1.1]

  submitForm: (e) ->
    e.preventDefault()

    content = {}
    for field in @bucket.get('fields')
      content[field.slug] = @subview("field_#{field.slug}").getValue()

    @model.set content: content

    status = @model.get('status')
    @model.set status: 'draft' if status is 'draft'
    @model.set status: 'live' unless @model.get('_id')

    @model.set('status', 'live')
    @submit @model.save(@formParams(), wait: yes)

  clickDelete: (e) ->
    e.preventDefault()

    if confirm "Are you sure you want to delete #{@model.get('title')}?"
      @model.destroy(wait: yes).done =>
        @keepElement = yes

  dispose: ->
    if @keepElement and @$el
      $el = @$el.css position: 'absolute', width: '100%'
      TweenLite.to $el, .4,
        scale: .98
        opacity: 0
        y: '+200px'
        rotate: 1
        onComplete: ->
          $el.remove()

    super

  clickDraft: (e) ->
    e.preventDefault()
    @model.set('status', 'draft')
    @submit @model.save(@formParams(), wait: yes)

  @mixin FormMixin
