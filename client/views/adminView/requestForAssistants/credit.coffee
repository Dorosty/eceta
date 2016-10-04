component = require '../../../utils/component'
modal = require '../../../singletons/modal'
gradeInput = require '../../../components/restrictedInput/grade'
{generateId} = require '../../../utils/dom'
{extend, toEnglish} = require '../../../utils'

module.exports = component 'requestForAssistantsCredit', ({dom, events, state, service, returnObject}) ->
  {E, text, setStyle, append, empty} = dom
  {onEvent, onEnter} = events

  ids = [0..1]

  grades = []

  gpa = E gradeInput
  setStyle gpa, class: id: ids[0], 'form-control'

  message = E 'textarea', id: ids[1], class: 'form-control', minHeight: 100, minWidth: '100%', maxWidth: '100%'

  isTrained = E 'input', type: 'checkbox', class: 'form-control'

  contents = [
    gradesContainer = E()
    E class: 'form-group',
      E 'label', for: ids[0], 'معلد کل'
      gpa
    E class: 'form-group',
      E 'label', for: ids[1], 'پیام برای استاد'
      message
    E class: 'checkbox',
      E 'label',
        text 'در کارگاه شرکت کرده‌است.'
        isTrained
  ]

  allInputs = [gpa, message, isTrained]

  setEnabled = ->
    modal.instance.setEnabled gpa.value()

  onEvent [gpa], ['input', 'pInput'], setEnabled

  onEnter [gpa, isTrained], ->
    modal.instance.submit()

  allInputs.forEach (input) ->
    onEvent input, ['focus', 'input', 'change'], ->
      input.dirty = true

  returnObject
    credit: -> (requestForAssistant) ->
      allInputs.forEach (input) ->
        input.dirty = false
      empty gradesContainer
      offering = (offerings.filter ({id}) -> String(id) is String(requestForAssistant.offeringId))[0]
        grades = offering.requiredCourses
        .map (_id) -> (courses.filter ({id}) -> String(id) is String(_id))[0]
        .forEach (course) ->
          grade = (requestForAssistant.grades.filter ({courseId}) -> String(courseId) is String(course.id))[0]?.grade
          grades.push g = E class: 'form-group',
            E 'label', for: id = generateId(), "نمره درس #{course.name}"
            input = E 'input', id: id, class: 'form-control', value: grade
          onEnter g, ->
            modal.instance.submit()
          append gradesContainer, g
          {course, input}
      state.all ['requestForAssistants', 'offerings', 'courses'], once: true, ([requestForAssistants, offerings, courses]) ->
        requestForAssistant = (requestForAssistants.filter ({id}) -> String(id) is String(requestForAssistant.id))[0]
        unless requestForAssistant
          return modal.instance.hide()
        unless gpa.dirty
          setStyle gpa, value: requestForAssistant.gpa
        unless message.dirty
          setStyle message, value: requestForAssistant.message
        unless isTrained.dirty
          setStyle isTrained, checked: requestForAssistant.isTrained
        modal.instance.display
          enabled: true
          autoHide: true
          title: 'جزئیات/ویرایش درخواست'
          submitText: 'ثبت تغییرات'
          closeText: 'لغو تغییرات'
          contents: contents
          submit: ->
            service.updateRequestForAssistant
              id: requestForAssistant.id
              gpa: gpa.value()
              message: message.value()
              isTrained: isTrained.checked()
              grades: grades.map ({course, input}) ->
                courseId: course.id
                grade: input.value()