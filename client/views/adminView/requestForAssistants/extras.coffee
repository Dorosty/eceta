component = require '../../../utils/component'
sendEmail = require '../sendEmail'

module.exports = component 'requestForAssistantsExtras', ({dom, events, returnObject}, {offeringIds, goToRequestForAssistants}) ->
  {E, setStyle, show, hide} = dom
  {onEvent} = events

  view = E 'span', null,
    if offeringIds
      [
        E 'span', marginRight: 10, "شما در حال مشاهده درخواست‌های مربوط به #{offeringIds.length} فراخوان هستید."
        do ->
          button = E class: 'btn btn-default', marginRight: 10, 'مشاهده همه درخواست‌ها'
          onEvent button, 'click', ->
            goToRequestForAssistants()
          button
      ]
    E class: 'btn-group', marginRight: 10,
      hide sendEmailToStudents = E class: 'btn btn-default'
      hide sendEmailToProfessors = E class: 'btn btn-default'

  _sendEmail = E sendEmail

  studentIds = professorIds = undefined

  onEvent sendEmailToProfessors, 'click', -> _sendEmail.show professorIds
  onEvent sendEmailToStudents, 'click', -> _sendEmail.show studentIds

  returnObject
    update: (descriptors) ->
      selectedDescriptors = descriptors.filter ({selected}) -> selected
      if selectedDescriptors.length
        show sendEmailToStudents
        show sendEmailToProfessors
        studentIds = Object.keys(selectedDescriptors.reduce ((acc, {entity}) ->
          acc[entity.studentId] = true
          acc
        ), {})
        setStyle sendEmailToStudents, text: "ارسال ایمیل به #{studentIds.length} دانشجو انتخاب شده"
        professorIds = Object.keys(selectedDescriptors.reduce ((acc, {entity}) ->
          acc[entity.professorId] = true
          acc
        ), {})
        setStyle sendEmailToProfessors, text: "ارسال ایمیل به #{professorIds.length} استاد انتخاب شده"
      else
        hide sendEmailToStudents
        hide sendEmailToProfessors

  view