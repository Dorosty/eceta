component = require '../../utils/component'
stateSyncedDropdown = require '../../components/dropdown/stateSynced'
{toEnglish, compare} = require '../../utils'
{generateId} = require '../../utils/dom'

module.exports = component 'adminStaticDataView', ({dom, events, state, service, others}) ->
  {E, setStyle, enable, disable, loading} = dom
  {onEvent} = events
  {loading} = others

  service.getTerms()
  service.getCurrentTerm()

  id = generateId()
  terms = E stateSyncedDropdown,
    stateName: 'terms'
    selectedIdStateName: 'currentTerm'
    sortCompare: (a, b) -> compare b, a
  setStyle terms, {id}

  view = E null,
    noData = E null, 'در حال بارگذاری...'
    yesData = E class: 'form-horizontal', marginTop: 40,
      E class: 'form-group ',
        E 'label', for: id, class: 'control-label col-md-2', 'ترم جاری'
        E class: 'col-md-4',
          terms
      submit = E class: 'btn btn-primary', 'ثبت تغییرات'

  onEvent submit, 'click', ->
    disable submit
    service.setStaticData [key: 'currentTerm', value: toEnglish terms.value()]
    .fin ->
      terms.undirty()
      enable submit

  loading ['terms', 'currentTerm'], yesData, noData

  view