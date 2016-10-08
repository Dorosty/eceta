component = require '../../utils/component'
modal = require '../../singletons/modal'
gradeInput = require '../../components/restrictedInput/grade'
{generateId} = require '../../utils/dom'
{toEnglish} = require '../../utils'

module.exports = component 'studentRequestForAssistant', ({dom, state, service, returnObject}) ->
  {E, text, setStyle, empty} = require './utils'

  ids = [0..2].map -> generateId()   

  gpa = E gradeInput
  setStyle gpa, id: ids[0], class: 'form-control'
  message = E 'textarea', id: ids[1], class: 'form-control', minHeight: 100, minWidth: '100%', maxWidth: '100%'
  isTrained = E 'input', id: ids[2], type: 'checkbox'

  contents = [
    gradeInputsPlaceholder = E 'span'
    E class: 'form-group',
      E 'label', for: ids[0], 'معدل کل'
      gpa
    E class: 'form-group',
      E 'label', for: ids[1], 'پیام برای استاد (اختیاری)'
      message
    E class: 'checkbox',
      E 'label', null,
        isTrained
        text 'در کارگاه آموزش دستیاران شرکت کرده‌ام'
  ]

  grades = []

  onEvent gpa, ['input', 'pInput'], setEnabled = ->
    modal.instance.setEnabled grades.concat([gpa]).every (x) -> x.value() and x.value().charAt(x.value.length - 1) isnt '.'
  
  onEnter [gpa, isTrained], ->
    modal.instance.submit()

  display = (isEdit) -> (offering) ->
    state.all allowNull: true, once: true, ['grades', 'gpa', 'isTrained'], ([gradeValues = {}, gpaValue, isTrainedValue]) ->
      grades = offering.requiredCourses.map ({id, name}) ->
        input = E gradeInput
        id = generateId()
        setStyle input, class: 'form-control', value: if offering.requestForAssistant
            (offering.requestForAssistant.grades.filter ({courseId}) -> String(courseId) is String(id))[0].grade
          else
            gradeValues[id]
        onEvent input, ['input', 'pInput'], setEnabled
        append gradeInputsPlaceholder, E class: 'form-group',
          E 'label', for: id, "نمره درس #{name}"
          input
        input

      setStyle gpa, value: offering.requestForAssistant?.gpa or gpaValue
      setStyle message, value: offering.requestForAssistant?.message
      setStyle isTrained, checked: offering.requestForAssistant?.isTrained or isTrainedValue

      modal.instance.display
        autoHide: true
        title: "ثبت درخواست دستیاری برای درس #{offering.courseName}"
        submitText: if isEdit then 'ویرایش درخواست' else 'ثبت'
        contents: contents
        submit: ->
          offering.requiredCourses.forEach ({id}, i) ->
            gradeValues[id] = grades[i].value
          state.grades.set gradeValues

          state.gpa.set gpa.value

          state.isTrained.set isTrained.checked

          service.sendRequestForAssistant
            offeringId: offering.id
            gpa: +toEnglish gpa.value
            grades: grades.map (grade, i) -> grade: +toEnglish(grade.value), courseId: +offering.requiredCourses[i].id
            isTrained: isTrained.checked
            message: message.value

  returnObject
    send: display false
    edit: display true