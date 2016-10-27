component = require '../../utils/component'
table = require '../../components/table'
searchBoxStyle = require '../../components/table/searchBoxStyle'
stateSyncedDropdown = require '../../components/dropdown/stateSynced'
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

  termDropdown = E stateSyncedDropdown,
    stateName: 'terms'
    selectedIdStateName: 'currentTerm'
  setStyle termDropdown, searchBoxStyle.font
  setStyle termDropdown.input, searchBoxStyle.input
  termDropdown.showEmpty true

  view = E null,
    noData = E null, 'در حال بارگذاری...'
    yesData = E class: 'row', margin: '10px 0',
      E 'a', class: 'btn btn-success', href: '/notTrainedStudents.xlsx', 'دریافت فایل اکسل'
      E marginTop: 30,
        tableInstance = E table,
          headers: [
            {name: 'نام کامل دانشجو', key: 'fullName', searchBox: fullNameInput}
            {name: 'شماره دانشجویی', key: 'golestanNumber', searchBox: golestanNumberInput}
            {name: 'ترم', key: 'termId', searchBox: termDropdown}
            {name: 'ایمیل', englishKey: 'email'}
            {name: 'مقطع', key: 'degree'}
          ]

  loading ['persons', 'offerings', 'currentTerm', 'requestForAssistants'], yesData, noData

  students = []
  update = ->
    fullName = fullNameInput.value()
    golestanNumber = golestanNumberInput.value()
    term = termDropdown.value()
    filteredStudents = students
    if fullName
      filteredStudents = filteredStudents.filter (person) -> textIsInSearch person.fullName, fullName
    if golestanNumber
      filteredStudents = filteredStudents.filter (person) -> textIsInSearch person.golestanNumber, golestanNumber
    if ~term
      filteredStudents = filteredStudents.filter (person) -> textIsInSearch person.termId, term
    tableInstance.setData filteredStudents

  state.all ['persons', 'offerings', 'requestForAssistants'], ([persons, offerings, requestForAssistants]) ->
    students = persons
    .filter (student) ->
      requestForAssistants.some (requestForAssistant) ->
        if String(requestForAssistant.studentId) is String(student.id) and requestForAssistant.status is 'تایید شده' and requestForAssistant.isTrained is false
          offerings.some ({id, termId}) ->
            if String(id) is String(requestForAssistant.offeringId)
              student.termId = termId
              true
    update()

  onEvent [fullNameInput, golestanNumberInput, termDropdown.input], ['input', 'pInput'], update

  view