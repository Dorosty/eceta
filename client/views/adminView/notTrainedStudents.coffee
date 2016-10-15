component = require '../../utils/component'
table = require '../../components/table'
searchBoxStyle = require '../../components/table/searchBoxStyle'
numberInput = require '../../components/restrictedInput/number'
{textIsInSearch} = require '../../utils'

module.exports = component 'notTrainesdStudents', ({dom, events, state, service, others}) ->
  {E, setStyle} = dom
  {onEvent} = events
  {loading} = others

  service.getPersons()
  service.getOfferings()
  service.getCurrentTerm()
  service.getRequestForAssistants()

  fullNameInput = E 'input', searchBoxStyle.textbox
  golestanNumberInput = E numberInput, true
  setStyle golestanNumberInput, searchBoxStyle.textbox

  view = E null,
    noData = E null, 'در حال بارگزاری...'
    yesData = [
      E class: 'row', margin: '10px 0',
        E 'a', class: 'btn btn-success', href: '/notTrainedStudents.xlsx', 'دریافت فایل اکسل'
        E marginTop: 30,
          tableInstance = E table,
            headers: [
              {name: 'نام کامل', key: 'fullName', searchBox: fullNameInput}
              {name: 'شماره دانشجویی', key: 'golestanNumber', searchBox: golestanNumberInput}
              {name: 'ایمیل', englishKey: 'email'}
              {name: 'مقطع', key: 'degree'}
            ]
    ]

  loading ['persons', 'offerings', 'currentTerm', 'requestForAssistants'], yesData, noData

  students = []
  update = ->
    fullName = fullNameInput.value()
    golestanNumber = golestanNumberInput.value()
    filteredStudents = students
    if fullName
      filteredStudents = filteredStudents.filter (person) -> textIsInSearch person.fullName, fullName
    if golestanNumber
      filteredStudents = filteredStudents.filter (person) -> textIsInSearch person.golestanNumber, golestanNumber
    tableInstance.setData filteredStudents

  state.all ['persons', 'offerings', 'currentTerm', 'requestForAssistants'], ([persons, offerings, currentTerm, requestForAssistants]) ->
    students = persons
    .filter (student) ->
      requestForAssistants.some (requestForAssistant) ->
        if String(requestForAssistant.studentId) is String(student.id) and requestForAssistant.status is 'تایید شده' and requestForAssistant.isTrained is false
          offerings.some ({id, termId}) -> String(id) is String(requestForAssistant.offeringId) and termId is currentTerm
    update()

  onEvent [fullNameInput, golestanNumberInput], ['input', 'pInput'], update

  view