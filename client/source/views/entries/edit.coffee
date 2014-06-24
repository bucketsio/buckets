_ = require 'underscore'

PageView = require 'views/base/page'
FormMixin = require 'views/base/mixins/form'
tpl = require 'templates/entries/edit'

module.exports = class EntryEditView extends PageView
  className: 'EntryEditView'
  template: tpl
  optionNames: PageView::optionNames.concat ['bucket', 'user']

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
      bucket: @bucket?.toJSON()
      user: @user?.toJSON()
      fields: fields
      newTitle: "New #{@bucket.get('singular')}"

  render: ->
    super
    TweenLite.from @$('.panel'), .5,
      scale: .7
      opacity: 0
      ease: Elastic.easeInOut
      easeParams: [.4, 1.1]

  submitForm: (e) ->
    e.preventDefault()
    status = @model.get('status')
    @model.set status: 'draft' if status is 'draft'
    @model.set status: 'live' unless @model.get('_id')

    @model.set('status', 'live')
    @submit @model.save(@formParams(), wait: yes)

  clickDelete: (e) ->
    e.preventDefault()

    if confirm 'Are you sure?'
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
