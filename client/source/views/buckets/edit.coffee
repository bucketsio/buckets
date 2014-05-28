PageView = require 'views/base/page'

tpl = require 'templates/buckets/edit'

module.exports = class BucketEditView extends PageView
  template: tpl
  autoRender: yes

  events:
    'submit form': 'submitForm'
    'click .swatches div': 'selectSwatch'
    'click [href="#delete"]': 'clickDelete'

  submitForm: (e) ->
    e.preventDefault()
    data = @$(e.currentTarget).formParams(no)

    data.color = @$('.colors div.selected').data('value')
    data.icon = @$('.icons div.selected').data('value')

    @model.save(data)

  selectSwatch: (e) ->
    e.preventDefault()
    $el = @$(e.currentTarget)
    $el.addClass('selected').siblings().removeClass 'selected'

  clickDelete: (e) ->
    e.preventDefault()
    if confirm 'Are you sure?'
      @model.destroy(wait: yes).done ->
        toastr.success 'Bucket deleted'