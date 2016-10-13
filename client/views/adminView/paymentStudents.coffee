component = require '../../utils/component'
crudPage = require './crudPage'
searchBoxStyle = require '../../components/table/searchBoxStyle'
numberInput = require '../../components/restrictedInput/number'
{extend, textIsInSearch} = require '../../utils'

module.exports = component 'notTrainesdStudents', ({dom, events, state, service}) ->
  {E, setStyle} = dom
  {onEvent} = events

  service.getPersons()
  service.getOfferings()
  service.getCourses()
  service.getCurrentTerm()
  service.getRequestForAssistants()

  fullNameInput = E 'input', searchBoxStyle.textbox
  golestanNumberInput = E numberInput, true
  setStyle golestanNumberInput, searchBoxStyle.textbox
  courseNameInput = E 'input', searchBoxStyle.textbox
  courseNumberInput = E numberInput, true
  setStyle courseNumberInput, searchBoxStyle.textbox
  professorFullNameInput = E 'input', searchBoxStyle.textbox
  professorGolestanNumberInput = E numberInput, true
  setStyle professorGolestanNumberInput, searchBoxStyle.textbox

  view = E null,
    noData = E null, 'در حال بارگزاری...'
    yesData = [
      E class: 'row', margin: '10px 0',
        E marginTop: 30,
          E 'a', class: 'btn btn-success', href: '/paymentStudents.xlsx', 'دریافت فایل اکسل'
          tableInstance = E table,
            headers = headers: [
              {name: 'نام کامل', key: 'fullName', searchBox: fullNameInput}
              {name: 'شماره دانشجویی', key: 'golestanNumber', searchBox: golestanNumberInput}
              {name: 'نام درس', key: 'courseName', searchBox: courseNameInput}
              {name: 'شماره درس', key: 'courseName', searchBox: courseNumberInput}
              {name: 'نام کامل استاد', key: 'professorFullName', searchBox: professorFullNameInput}
              {name: 'شماره پرسنلی استاد', key: 'professorGolestanNumber', searchBox: professorGolestanNumberInput}
              {name: 'مقطع', key: 'degree'}
              {name: 'دستیار اصلی است', key: 'isChiefTa'}
            ]
            sort: 
              header: headers[2]
              direction: 'up'
    ]

  students = []
  update = ->
    fullName = fullNameInput.value()
    golestanNumber = golestanNumberInput.value()
    courseName = courseNameInput.value()
    courseNumber = courseNumberInput.value()
    professorFullName = professorFullNameInput.value()
    professorGolestanNumber = professorGolestanNumberInput.value()
    filteredStudents = students
    if fullName
      filteredStudents = filteredStudents.filter (person) -> textIsInSearch person.fullName, fullName
    if golestanNumber
      filteredStudents = filteredStudents.filter (person) -> textIsInSearch person.golestanNumber, golestanNumber
    if courseName
      filteredStudents = filteredStudents.filter (person) -> textIsInSearch person.courseName, courseName
    if courseNumber
      filteredStudents = filteredStudents.filter (person) -> textIsInSearch person.courseNumber, courseNumber
    if professorFullName
      filteredStudents = filteredStudents.filter (person) -> textIsInSearch person.professorFullName, professorFullName
    if professorGolestanNumber
      filteredStudents = filteredStudents.filter (person) -> textIsInSearch person.professorGolestanNumber, professorGolestanNumber
    tablein.setData filteredStudents

  state.all ['persons', 'professors', 'offerings', 'currentTerm', 'courses', 'requestForAssistants'],
    ([persons, professors, offerings, currentTerm, courses, requestForAssistants]) ->
    students = persons
    .filter (student) ->
      requestForAssistants.some (requestForAssistant) ->
        if String(requestForAssistant.studentId) is String(student.id) and requestForAssistant.status is 'تایید شده'
          offerings.some (offering) ->
            if String(offering.id) is String(requestForAssistant.id) and offering.termId is currentTerm
              [course] = courses.filter ({id}) -> String(id) is String(offering.courseId)
              [professor] = professors.filter ({id}) -> String(id) is String(offering.professorId)
              extend student,
                courseName: course.name
                courseNumber: course.number
                professorFullName: professor.fullName
                professorGolestanNumber: professor.golestanNumber
                isChiefTa: requestForAssistant.isChiefTa
              true
    update()

  onEvent [fullNameInput, golestanNumberInput], ['input', 'pInput'], update

  view