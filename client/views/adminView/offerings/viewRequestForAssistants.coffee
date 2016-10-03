component = require '../../../utils/component'

module.exports = component 'offeringsViewRequestForAssistants', ({dom, events, returnObject}, goToRequestForAssistants) ->
  {E, show, hide, setStyle} = dom
  {onEvent} = events

  hide view = E class: 'btn btn-default', marginRight: 10

  offClick = undefined

  returnObject
    update: (descriptors) ->
      selectedEntities = descriptors.filter ({selected}) -> selected
      offClick?()
      if selectedEntities.length
        show view
        setStyle view, text: "مشاهده درخواست‌های #{selectedEntities.length} فراخوان انتخاب شده"
        offClick = onEvent view, 'click', ->
          goToRequestForAssistants selectedEntities.map ({entity}) -> entity.id
      else
        hide view

  view