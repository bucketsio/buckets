Handlebars = require 'hbsfy/runtime'
_ = require 'underscore'

createLabel = (text, name, options={}) ->

  _.defaults options,
    className: 'control-label'
    required: no

  text += "<span title=\"This field is required.\" class=\"show-tooltip text-danger\">*</span>" if options.required

  tag 'label',
    for: "input-#{name}"
    className: options.className
  , text

wrap = (content, options={}) ->
  _.defaults options,
    label: null
    help: null
    className: 'form-group'
    name: ''
    required: no

  content = createLabel(options.label, options.name, required: options.required) + content if options.label
  content += tag 'p', {className: 'help-block'}, options.help if options.help

  tag 'div', class: options.className, content

tag = (el, attrs={}, content='', options={}) ->
  html = "<#{el}"
  for key, val of attrs
    key = 'class' if key is 'className'
    html += " #{key}=\"#{val}\"" if val? and val isnt ''
  html += ">"
  html += content if content
  html += "</#{el}>" unless options.selfClosing

  new Handlebars.SafeString html

Handlebars.registerHelper 'input', (name, value, options) ->
  settings = _.defaults options.hash,
    className: 'form-control'
    type: 'text'
    required: no

  params =
    name: name
    value: value
    className: settings.className
    id: settings.id
    placeholder: settings.placeholder
    tabindex: 1
    type: settings.type
    id: "input-#{name}"
    autocomplete: 'off'

  params.className += " input-#{settings.size}" if settings.size

  if settings.slugName
    params.className += ' has-slug'
    _.extend params,
      'data-sluggify': settings.slugName

  input = tag('input', params, false, selfClosing: true)

  if settings.slugName
    slug = tag('input', {
      className: 'form-control input-slug input-sm'
      type: 'text'
      name: settings.slugName
      value: settings.slugValue
      placeholder: 'slug'
      tabindex: 0
    })
    input += slug

  wrap input,
    label: settings.label
    help: settings.help
    required: settings.required
    name: params.name

Handlebars.registerHelper 'textarea', (name, value, options) ->

  settings = _.defaults options.hash,
    tabindex: 1
    className: 'form-control'
    size: null

  settings.rows = 20 if settings.size is 'lg'
  settings.rows = 5 if settings.size is 'sm'

  textarea = tag 'textarea',
    name: name
    className: settings.className
    id: "input-#{name}"
    placeholder: settings.placeholder
    tabindex: settings.tabindex
    rows: settings.rows
  , value

  if settings.label
    wrap textarea,
      label: settings.label
      help: settings.help
      name: name
      required: settings.required
  else
    textarea

Handlebars.registerHelper 'submit', (text, options) ->

  settings = _.defaults options.hash,
    className: 'btn btn-primary ladda-button'
    tabindex: 1

  tag 'button',
    className: settings.className
    'data-style': 'zoom-in'
    type: 'submit'
    tabindex: settings.tabindex
  , text

Handlebars.registerHelper 'hidden', (name, value) ->
  tag 'input',
    type: 'hidden'
    name: name
    value: value

Handlebars.registerHelper 'checkbox', (name, value, options) ->
  label = options.hash.label

  params =
    type: 'checkbox'
    name: name
    value: 1
    tabIndex: 1

  params.checked = 'checked' if value

  cb = tag 'input', params
  cb = tag 'label', {className: 'control-label'}, cb + " #{label}" if label
  wrap cb,
    help: options.hash.help
    className: 'checkbox'

Handlebars.registerHelper 'select', (name, value, selectOptions, options) ->

  return unless selectOptions?.length > 0

  settings = _.defaults options.hash,
    className: 'form-control'
    valueKey: '_id'
    nameKey: 'name'
    tabIndex: 1

  settings.selected = 'selected' if value

  optionEls = []
  for opt in selectOptions
    optionEls.push tag 'option',
      value: opt[settings.valueKey]
      selected: if opt[settings.valueKey] is value
        "selected"
      else
        ""
    , opt[settings.nameKey]

  wrap tag('select',
    className: settings.className
    tabindex: settings.tabindex
    name: name
  , optionEls.join ''),
    label: settings.label
    help: settings.help
