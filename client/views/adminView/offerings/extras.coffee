component = require '../../../utils/component'
sendEmail = require '../sendEmail'

module.exports = component 'offeringsExtras', ({dom, events, returnObject}, {goToRequestForAssistants}) ->
  {E, setStyle, show, hide} = dom
  {onEvent} = events

  view = E 'span', null,
    hide sendEmailToProfessors = E class: 'btn btn-default', marginRight: 10
    hide viewRequestForAssistants = E class: 'btn btn-default', marginRight: 10

  _sendEmail = E sendEmail

  professors = undefined

  onEvent sendEmailToProfessors, 'click', -> _sendEmail.show professors.map ({id}) -> id

  offViewRequestForAssistantsClick = undefined

  returnObject
    update: (descriptors) ->
      selectedDescriptors = descriptors.filter ({selected}) -> selected
      offViewRequestForAssistantsClick?()
      if selectedDescriptors.length
        show [sendEmailToProfessors, viewRequestForAssistants]
        professors = Object.keys(selectedDescriptors.reduce ((acc, {entity}) ->
          acc[entity.professorId] = true
          acc
        ), {})
        setStyle sendEmailToProfessors, text: "ارسال ایمیل به #{professors.length} استاد انتخاب شده"
        setStyle viewRequestForAssistants, text: "مشاهده درخواست‌های #{selectedDescriptors.length} فراخوان انتخاب شده"
        offViewRequestForAssistantsClick = onEvent viewRequestForAssistants, 'click', ->
          goToRequestForAssistants selectedDescriptors.map ({entity}) -> entity.id
      else
        hide [sendEmailToStudents, viewRequestForAssistants]

  view