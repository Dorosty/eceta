component = require '../../../utils/component'
sendEmail = require '../sendEmail'

module.exports = component 'offeringsExtras', ({dom, events, returnObject}, {goToRequestForAssistants}) ->
  {E, setStyle, show, hide} = dom
  {onEvent} = events

  view = E 'span', null,
    hide sendEmailToProfessors = E class: 'btn btn-default', marginRight: 10
    hide viewRequestForAssistants = E class: 'btn btn-default', marginRight: 10

  _sendEmail = E sendEmail

  professorIds = undefined

  onEvent sendEmailToProfessors, 'click', -> _sendEmail.show professorIds

  offViewRequestForAssistantsClick = undefined

  returnObject
    update: (descriptors) ->
      selectedDescriptors = descriptors.filter ({selected}) -> selected
      offViewRequestForAssistantsClick?()
      if selectedDescriptors.length
        show [sendEmailToProfessors, viewRequestForAssistants]
        professorIds = Object.keys(selectedDescriptors.reduce ((acc, {entity}) ->
          acc[entity.professorId] = true
          acc
        ), {})
        setStyle sendEmailToProfessors, text: "ارسال ایمیل به #{professorIds.length} استاد انتخاب شده"
        setStyle viewRequestForAssistants, text: "مشاهده درخواست‌های #{selectedDescriptors.length} فراخوان انتخاب شده"
        offViewRequestForAssistantsClick = onEvent viewRequestForAssistants, 'click', ->
          goToRequestForAssistants selectedDescriptors.map ({entity}) -> entity.id
      else
        hide [sendEmailToProfessors, viewRequestForAssistants]

  view