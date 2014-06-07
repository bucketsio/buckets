Handlebars = require 'hbsfy/runtime'
_ = require 'underscore'

createLabel = (text, name) ->
  tag 'label',
    for: "input-#{name}"
  , text

wrap = (content) ->
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

  if options.hash?.sluggify
    _.extend params,
      'data-sluggify': options.hash.sluggify

  wrap tag 'input', params, false, selfClosing: true

Handlebars.registerHelper 'textarea', (name, value, options) ->
  settings = options.hash

  textarea = tag 'textarea',
    name: name
    className: settings.className
    id: "input-#{name}"
    placeholder: settings.placeholder
    tabindex: settings.tabindex
    rows: settings.rows
  , value


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
  settings = _.defaults options.hash,
    label: false
    tabindex: ''

  checkedText = if value is true then ' checked' else ''
  labelText = if settings.label then settings.label else ''

  tag 'label', {}, tag 'input',
    type: 'checkbox'
    name: name

Handlebars.registerHelper 'select', (name, value, selectOptions, options) ->

  console.log 'select', selectOptions, options.hash

  return unless selectOptions?.length > 0

  settings = _.defaults options.hash,
    placeholder: ''
    className: ''
    label: null
    tabindex: ''
    valueKey: 'value'
    nameKey: 'name'

  o = []
  o.push createLabel settings.label, name if settings.label
  o.push """<select name="#{name}">"""
  for opt in selectOptions
    isSelected = if opt[settings.valueKey] is value
      "selected"
    else
      ""

    o.push tag 'option',
      value: opt[settings.valueKey]
      selected: isSelected
    , opt[settings.nameKey]
  o.push "</select>"

  new Handlebars.SafeString o.join ''
