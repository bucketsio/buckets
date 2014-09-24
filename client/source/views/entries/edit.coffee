_ = require 'underscore'

Model = require 'lib/model'
PageView = require 'views/base/page'
FormMixin = require 'views/base/mixins/form'
FieldTypeInputView = require 'views/fields/input'
Chaplin = require 'chaplin'

tpl = require 'templates/entries/edit'

mediator = require 'mediator'

module.exports = class EntryEditView extends PageView
  className: 'EntryEditView'
  template: tpl
  optionNames: PageView::optionNames.concat ['bucket']
  region: 'detail'
  regions:
    'user-fields': '.userFields'
  mixins: [FormMixin]

  events:
    'submit form': 'submitForm'
    'click [href="#delete"]': 'clickDelete'
    'click [href="#draft"]': 'clickDraft'
    'click [href="#date"]': 'clickDate'
    'click [href="#publish"]': 'clickPublish'
    'click [href="#copy"]': 'clickCopy'
    'click [href="#reject"]': 'clickReject'
    'keydown textarea, [type=text], [type=number]': 'keyDown'
    'keyup textarea, [type=text], [type=number]': 'keyUp'

  keyUp: (e) ->
    if @cmdActive and e.which is 91
      @cmdActive = false
      e

  keyDown: (e) ->
    if @cmdActive and e.which is 13
      @$('form').submit()
    @cmdActive = e.metaKey
    e

  getTemplateData: ->
    fields = @bucket.get('fields')

    _.map fields, (field) =>
      field.value = @model.get(field.slug)
      field

    _.extend super,
      bucket: @bucket.toJSON()
      user: @user
      fields: fields
      newTitle: if @bucket.get('titlePlaceholder') then _.sample @bucket.get('titlePlaceholder').split('|') else "New #{@bucket.get('singular')}"

  render: ->
    super
    content = @model.get('content')

    _.each @bucket.get('fields'), (field) =>
      fieldValue = content[field.slug]
      fieldModel = new Model _.extend field, value: fieldValue

      @subview 'field_'+field.slug, new FieldTypeInputView
        model: fieldModel

      return if field.fieldType in ['text', 'textarea', 'checkbox', 'number', 'cloudinary_image']

      # Otherwise ensure the plugin is loaded and see if one exists
      mediator.loadPlugin(field.fieldType).done =>
        plugin = mediator.plugins[field.fieldType]

        if plugin?
          if _.isFunction plugin.inputView
            return @subview 'field_'+field.slug, new plugin.inputView
              model: fieldModel
              region: 'user-fields'

          else if _.isString plugin.inputView
            return @subview 'field_'+field.slug, new FieldTypeInputView
              template: plugin.inputView
              model: fieldModel

        @subview("field_#{field.slug}").$el.html """
          <label class="text-danger">#{field.name}</label>
          <div class="alert alert-danger">
            <p>
              <strong>Warning:</strong>
              There was an error loading the input code for the <code>#{field.fieldType}</code> FieldType.<br>
            </p>
          </div>
        """

    # Convert keywords to input
    popularKeywords = new Bloodhound
      name: 'keywords'
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace('keyword')
      queryTokenizer: Bloodhound.tokenizers.whitespace
      prefetch:
        url: '/api/entries/keywords'
        ttl: 0
    popularKeywords.clearPrefetchCache()
    popularKeywords.initialize()

    $keywords = @$('[name="keywords"]')
    $keywords.tagsinput
      typeaheadjs:
        name: 'keywords'
        displayKey: 'keyword'
        valueKey: 'keyword'
        source: popularKeywords.ttAdapter()

    @$('.bootstrap-tagsinput').addClass 'form-control'

  submitForm: (e) ->
    e.preventDefault()

    content = {}
    for field in @bucket.get('fields')
      content[field.slug] = @subview("field_#{field.slug}").getValue?()
      continue if content[field.slug]

      data = @subview "field_#{field.slug}"
        .$el.formParams no
      simpleValue = data[field.slug]

      content[field.slug] = if simpleValue? then simpleValue else data

    @model.set content: content

    status = @model.get 'status'
    @model.set status: 'live' unless @model.get 'id'
    @submit @model.save @formParams(), wait: yes

  clickDelete: (e) ->
    e.preventDefault()

    if confirm "Are you sure you want to delete #{@model.get('title')}?"
      @model.destroy(wait: yes)

  clickDraft: (e) ->
    e.preventDefault()
    @model.set status: 'draft'
    @submit @model.save(@formParams(), wait: yes)

  clickDate: (e) ->
    e.preventDefault()
    @$('.dateInput').removeClass 'hidden'
    $(e.currentTarget).parent().remove()
    @$('button.btn-primary').text 'Schedule'
    @$('.dateInput input').focus()

  clickPublish: (e) ->
    e.preventDefault()
    @model.set _.extend @formParams(), publishDate: 'Now', status: 'live'
    @submit @model.save @model.toJSON(), wait: yes

  clickReject: (e) ->
    e.preventDefault()
    @model.set _.extend @formParams(), publishDate: 'Now', status: 'rejected'
    @submit @model.save @model.toJSON(), wait: yes

  clickCopy: (e) ->
    e.preventDefault()

    newModel = @model.clone()
    newModel.set _.extend @formParams(),
      id: null
      publishDate: 'Now'
      status: 'draft'

    collection = @model.collection
    @model = newModel

    @submit(@model.save @model.toJSON(), wait: yes).done (newEntry) =>
      collection.add newModel
      newModel = null
      collection = null
      Chaplin.utils.redirectTo 'buckets#browse', {slug: @bucket.get('slug'), entryID: newEntry.id}

  dispose: ->
    unless @disposed
      @$('.panel').css(opacity: 0)
      @$('[name="keywords"]').tagsinput 'destroy'
    super
