Handlebars = require 'hbsfy/runtime'
_ = require 'underscore'

createLabel = (text, name, className="control-label") ->
  tag 'label',
    for: "input-#{name}"
    className: className
  , text

wrap = (content, options={}) ->
  _.defaults options,
    label: null
    help: null
    className: 'form-group'
  content = createLabel(options.label) + content if options.label
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

  params =
    name: name
    value: value
    className: settings.className
    id: settings.id
    placeholder: settings.placeholder
    tabindex: 0
    type: settings.type
    autocomplete: 'off'

  params.className += ' has-slug'

  if settings.slugName
    _.extend params,
      'data-sluggify': settings.slugName

  input = tag('input', params, false, selfClosing: true)

  if settings.slugName
    slug = tag('input', {
      className: 'form-control input-slug input-sm'
      name: settings.slugName
      value: settings.slugValue
      placeholder: 'slug'
      tabindex: '-1'
    })
    input += slug

  wrap input,
    label: settings.label
    help: settings.help

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

  if settings.label
    wrap textarea, label: settings.label, help: settings.help
  else
    textarea

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
  wrap cb,
    help: options.hash.help
    className: 'checkbox'

Handlebars.registerHelper 'select', (name, value, selectOptions, options) ->

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
  , optionEls.join ''),
    label: settings.label
    help: settings.help
