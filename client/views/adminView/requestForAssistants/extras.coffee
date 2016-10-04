component = require '../../../utils/component'
sendEmail = require './sendEmail'

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

  students = professors = undefined

  onEvent sendEmailToProfessors, 'click', -> _sendEmail.show professors.map ({id}) -> id
  onEvent sendEmailToStudents, 'click', -> _sendEmail.show students.map ({id}) -> id

  returnObject
    update: (descriptors) ->
      selectedDescriptors = descriptors.filter ({selected}) -> selected
      if selectedDescriptors.length
        show sendEmailToStudents
        show sendEmailToProfessors
        students = Object.keys(selectedDescriptors.reduce ((acc, {entity}) ->
          acc[entity.studentId] ?= true
          acc
        ), {})
        setStyle sendEmailToStudents, text: "ارسال ایمیل به #{students.length} دانشجو انتخاب شده"
        professors = Object.keys(selectedDescriptors.reduce ((acc, {entity}) ->
          acc[entity.professorId] ?= true
          acc
        ), {})
        setStyle sendEmailToProfessors, text: "ارسال ایمیل به #{professors.length} استاد انتخاب شده"
      else
        hide sendEmailToStudents
        hide sendEmailToProfessors

  view