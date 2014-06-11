Handlebars = require 'hbsfy/runtime'
_ = require 'underscore'

createLabel = (text, name) ->
  tag 'label',
    for: "input-#{name}"
    className: 'control-label'
  , text

wrap = (content, label) ->
  content = createLabel(label) + content if label
  tag 'div', class: 'form-group', content

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

  params =
    name: name
    value: value
    className: settings.className
    id: settings.id
    placeholder: settings.placeholder
    tabindex: 0
    type: settings.type
    autocomplete: 'off'

  if options.hash?.sluggify
    _.extend params,
      'data-sluggify': options.hash.sluggify

  wrap tag('input', params, false, selfClosing: true), settings.label

Handlebars.registerHelper 'textarea', (name, value, options) ->
  settings = options.hash

  textarea = tag 'textarea',
    name: name
    className: settings.className || 'form-control'
    id: "input-#{name}"
    placeholder: settings.placeholder
    tabindex: settings.tabindex
    rows: settings.rows
  , value

  wrap textarea, settings.label if settings.label


Handlebars.registerHelper 'submit', (text, options) ->

  settings = _.defaults options.hash,
    className: 'btn btn-primary ladda-button'

  tag 'button',
    className: settings.className
    'data-style': 'zoom-in'
    type: 'submit'
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

  params.checked = 'checked' if value

  cb = tag 'input', params
  cb = tag 'label', {}, cb + " #{label}" if label

  wrap cb

Handlebars.registerHelper 'select', (name, value, selectOptions, options) ->

  console.log 'select', selectOptions, options.hash

  return unless selectOptions?.length > 0

  settings = _.defaults options.hash,
    className: 'form-control'
    valueKey: '_id'
    nameKey: 'name'

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
  , optionEls.join ''), settings.label
