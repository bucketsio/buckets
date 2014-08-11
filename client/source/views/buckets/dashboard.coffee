_ = require 'underscore'
Chaplin = require 'chaplin'
PageView = require 'views/base/page'

mediator = require 'mediator'

suggestionTpl = require 'templates/entries/suggestion'
tpl = require 'templates/buckets/dashboard'

module.exports = class DashboardView extends PageView
  template: tpl

  events:
    'typeahead:selected': 'selectItem'

  render: ->
    super

    engine = new Bloodhound
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value')
      queryTokenizer: Bloodhound.tokenizers.whitespace
      prefetch: '/api/entries'
      remote: '/api/entries/?query=%QUERY*'

    engine.initialize()
    engine.clearRemoteCache();

    @$search = @$('[name="search"]').typeahead
      highlight: yes
    ,
      name: 'entries',
      displayKey: 'title'
      templates: {
          empty: """
           <div class="tt-empty text-muted">
              No matching entries.
            </div>
          """
          suggestion: suggestionTpl
        }
      source: engine.ttAdapter()

    _.defer => @$search.focus()

  selectItem: (e, item) ->
    Chaplin.utils.redirectTo 'buckets#browse',
      slug: item.bucket.slug
      entryID: item._id
