component = require '../../utils/component'
table = require '../../components/table'
searchBoxStyle = require '../../components/table/searchBoxStyle'
numberInput = require '../../components/restrictedInput/number'
{extend, textIsInSearch} = require '../../utils'

module.exports = component 'notTrainesdStudents', ({dom, events, state, service, others}) ->
  {E, setStyle} = dom
  {onEvent} = events
  {loading} = others

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
    noData = E null, 'در حال بارگذاری...'
    yesData = [
      E class: 'row', margin: '10px 0',
        E 'a', class: 'btn btn-success', href: '/paymentStudents.xlsx', 'دریافت فایل اکسل'
        E marginTop: 30,
          tableInstance = E table,
            headers: headers = [
              {name: 'نام کامل', key: 'fullName', searchBox: fullNameInput}
              {name: 'شماره دانشجویی', key: 'golestanNumber', searchBox: golestanNumberInput}
              {name: 'نام درس', key: 'courseName', searchBox: courseNameInput}
              {name: 'شماره درس', key: 'courseNumber', searchBox: courseNumberInput}
              {name: 'نام کامل استاد', key: 'professorFullName', searchBox: professorFullNameInput}
              {name: 'شماره پرسنلی استاد', key: 'professorGolestanNumber', searchBox: professorGolestanNumberInput}
              {name: 'مقطع', key: 'degree'}
              {name: 'دستیار اصلی است', key: 'isChiefTA'}
            ]
            sort: 
              header: headers[2]
              direction: 'up'
    ]

  loading ['persons', 'professors', 'offerings', 'currentTerm', 'courses', 'requestForAssistants'], yesData, noData

  requests = []
  update = ->
    fullName = fullNameInput.value()
    golestanNumber = golestanNumberInput.value()
    courseName = courseNameInput.value()
    courseNumber = courseNumberInput.value()
    professorFullName = professorFullNameInput.value()
    professorGolestanNumber = professorGolestanNumberInput.value()
    filteredRequests = requests
    if fullName
      filteredRequests = filteredRequests.filter (request) -> textIsInSearch request.fullName, fullName
    if golestanNumber
      filteredRequests = filteredRequests.filter (request) -> textIsInSearch request.golestanNumber, golestanNumber
    if courseName
      filteredRequests = filteredRequests.filter (request) -> textIsInSearch request.courseName, courseName
    if courseNumber
      filteredRequests = filteredRequests.filter (request) -> textIsInSearch request.courseNumber, courseNumber
    if professorFullName
      filteredRequests = filteredRequests.filter (request) -> textIsInSearch request.professorFullName, professorFullName
    if professorGolestanNumber
      filteredRequests = filteredRequests.filter (request) -> textIsInSearch request.professorGolestanNumber, professorGolestanNumber
    tableInstance.setData filteredRequests

  state.all ['persons', 'professors', 'offerings', 'currentTerm', 'courses', 'requestForAssistants'],
    ([persons, professors, offerings, currentTerm, courses, requestForAssistants]) ->
      requests = requestForAssistants
      .filter (request) ->
        if request.status isnt 'تایید شده'
          return false
        persons.some (student) ->
          if String(request.studentId) is String(student.id)
            offerings.some (offering) ->
              if String(offering.id) is String(request.offeringId) and offering.termId is currentTerm
                [course] = courses.filter ({id}) -> String(id) is String(offering.courseId)
                [professor] = professors.filter ({id}) -> String(id) is String(offering.professorId)
                extend request,
                  fullName: student.fullName
                  golestanNumber: student.golestanNumber
                  degree: student.degree
                  courseName: course.name
                  courseNumber: course.number
                  professorFullName: professor.fullName
                  professorGolestanNumber: professor.golestanNumber
                  isChiefTA: if request.isChiefTA then 'بله' else 'خیر'
                true
      update()

  onEvent [fullNameInput, golestanNumberInput, courseNameInput, courseNumberInput, professorFullNameInput, professorGolestanNumberInput] , ['input', 'pInput'], update

  view