component = require '../../utils/component'
modal = require '../../singletons/modal'
{toEnglish, compare} = require '../../utils'
{generateId} = require '../../utils/dom'

module.exports = component 'adminStaticDataView', ({dom, events, state, service, others}) ->
  {E, setStyle, enable, disable} = dom
  {onEvent} = events
  {loading} = others

  # service.getTerms()
  service.getCurrentTerm()

  view = E null,
    noData = E null, 'در حال بارگذاری...'
    yesData = E class: 'form-horizontal', marginTop: 40,
      termLabel = E 'label', class: 'control-label'
      submit = E class: 'btn btn-primary', marginRight: 10, 'رفتن به ترم بعد'

  onEvent submit, 'click', ->
    state.currentTerm.on once: true, (currentTerm) ->
      [year, part] = currentTerm.split '-'
      switch +part
        when 1
          part = 2
        when 2
          part = 1
          year++
      nextTerm = "#{year}-#{part}"
      modal.instance.display
        enabled: true
        autoHide: true
        title: ''
        submitType: 'danger'
        submitText: 'رفتن به ترم بعد'
        closeText: 'لغو'
        contents: E null, "با کلیک روی دکمه تایید ترم جاری به #{nextTerm} تغییر خواهد یافت. این کار غیر قابل بازگشت است."
        submit: ->
          service.setStaticData [key: 'currentTerm', value: nextTerm]

  loading ['currentTerm'], yesData, noData

  state.currentTerm.on (currentTerm) ->
    setStyle termLabel, text: 'ترم جاری: ' + currentTerm

  view