
credit = require './views/credit'

{E, setStyle, gradeInput, append, toPersian, toEnglish} = require './utils'

restyleCheckbox = (group, label, element) ->
  text = document.createTextNode label.innerText or label.innerHTML
  label.innerText = label.innerHTML = ''
  setStyle group, class: 'checkbox', marginBottom: 40
  setStyle element, class: ''
  append label, [element, text]

message = E 'textarea', class: 'form-control', minHeight: 100, minWidth: '100%', maxWidth: '100%'
gpa = gradeInput class: 'form-control'
isTrained = E 'input', type: 'checkbox'

module.exports = (isEdit, offering) ->

  state = require './state'
  service = require './service'
  modal = require './modal'

  state.all allowNull: true, once: true, ['grades', 'gpa', 'isTrained'], ([gradeValues = {}, gpaValue, isTrainedValue]) ->

    grades = offering.requiredCourses.map (i) ->
      gradeInput class: 'form-control', gradeValues[i]
    allGrades = [gpa].concat grades

    setStyle gpa, value: gpaValue
    setStyle isTrained, checked: isTrainedValue

    credit(
      getTitle: -> toPersian "ثبت درخواست دستیاری برای درس #{offering.courseName}"
      getSubmitText: -> if isEdit then 'ویرایش درخواست' else 'ثبت'
      isEnabled: -> allGrades.every (x) -> x.value and x.value.charAt(x.value.length - 1) isnt '.'
      fields: offering.requiredCourses.map ({id, name}, i) ->
        {name: "نمره درس #{toPersian name}", element: grades[i]}
      .concat [
        {name: 'معدل کل', element: gpa}
        {name: 'پیام برای استاد (اختیاری)', element: message, noEnter: true}
        {
          name: 'در کارگاه آموزش دستیاران شرکت کرده‌ام'
          element: isTrained
          restyle: restyleCheckbox
          setValue: (value, element) -> setStyle element, checked: value
        }
      ]
      create: ->
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
        .fin modal.hide
    )(false)()
