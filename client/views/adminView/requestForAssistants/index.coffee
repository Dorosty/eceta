component = require '../../../utils/component'
crudPage = require '../crudPage'
credit = require './credit'
multiselect = require './multiselect'
extras = require './extras'
searchBoxStyle = require '../../../components/table/searchBoxStyle'
dropdown = require '../../../components/dropdown'
stateSyncedDropdown = require '../../../components/dropdown/stateSynced'
{extend, compare, textIsInSearch} = require '../../../utils'

module.exports = component 'requestForAssistantsView', ({dom, events, state, service}, {goToRequestForAssistants, offeringIds}) ->
  {E, setStyle} = dom
  {onEvent} = events

  service.getPersons()
  service.getCourses()
  service.getOfferings()
  service.getTerms()
  service.getCurrentTerm()
  service.getRequestForAssistants()

  termDropdown = E stateSyncedDropdown,
    stateName: 'terms'
    selectedIdStateName: 'currentTerm'
  setStyle termDropdown, searchBoxStyle.font
  setStyle termDropdown.input, searchBoxStyle.input
  termDropdown.showEmpty true

  isTrainedDropdown = E dropdown, getTitle: (x) ->
    switch x
      when 0
        'بله'
      when 1
        'خیر'
  setStyle isTrainedDropdown, searchBoxStyle.font    
  setStyle isTrainedDropdown.input, searchBoxStyle.input
  isTrainedDropdown.showEmpty true
  isTrainedDropdown.update [0, 1]

  statusDropdown = E dropdown
  setStyle statusDropdown, searchBoxStyle.font    
  setStyle statusDropdown.input, searchBoxStyle.input
  statusDropdown.showEmpty true
  statusDropdown.update ['تایید شده', 'رد شده', 'در حال بررسی']

  professorNameInput = E 'input', searchBoxStyle.textbox
  courseNameInput = E 'input', searchBoxStyle.textbox
  studentNameInput = E 'input', searchBoxStyle.textbox

  view = E crudPage,
    entityName: 'درخواست'
    requiredStates: ['offerings', 'courses', 'persons', 'terms', 'currentTerm', 'requestForAssistants']
    noCreating: true
    entityId: 'id'
    headers: [
      {name: 'نام استاد', key: 'professorName', searchBox: professorNameInput}
      {name: 'نام درس', key: 'courseName', searchBox: courseNameInput}
      {name: 'نام دانشجو', key: 'studentName', searchBox: studentNameInput}
      {name: 'ترم', key: 'termId', searchBox: termDropdown}
      {
        name: 'در کارگاه شرکت کرده است'
        searchBox: isTrainedDropdown
        getValue: (requestForAssistant) ->
          if requestForAssistant.isTrained
            'بله'
          else
            'خیر'
        styleTd: (requestForAssistant, td) ->
          if requestForAssistant.isTrained
            setStyle td, color: 'green'
          else
            setStyle td, color: 'red'
      }
      {
        name: 'وضعیت'
        key: 'status'
        searchBox: statusDropdown
        styleTd: (requestForAssistant, td) ->
          switch requestForAssistant.status
            when 'تایید شده'
              setStyle td, color: 'green'
            when 'رد شده'
              setStyle td, color: 'red'
            else
              setStyle td, color: 'black'
      }
    ]
    extraButtonsBefore: multiselectInstance = E multiselect, (callback) -> view.setSelectedRows callback
    extraButtons: extrasInstance = E extras, {goToRequestForAssistants, offeringIds}
    onTableUpdate: (descriptors) ->
      multiselectInstance.setChecked descriptors
      extrasInstance.update descriptors
    credit: E(credit).credit
    deleteItem: (requestForAssistants) ->
      service.deleteRequestForAssistants requestForAssistant.map ({id}) -> id

  requestForAssistants = []
  update = ->
    professorName = professorNameInput.value()
    courseName = courseNameInput.value()
    studentName = studentNameInput.value()
    term = termDropdown.value()
    isTrained = isTrainedDropdown.value()
    status = statusDropdown.value()
    filteredRequestForAssistants = requestForAssistants
    console.log filteredRequestForAssistants
    if offeringIds
      filteredRequestForAssistants = filteredRequestForAssistants.filter (requestForAssistant) ->
        String(requestForAssistant.offeringId) in offeringIds.map (offeringId) -> String offeringId
    console.log filteredRequestForAssistants
    if professorName
      filteredRequestForAssistants = filteredRequestForAssistants.filter (requestForAssistant) ->
        textIsInSearch requestForAssistant.professorName, professorName, true, true
    console.log filteredRequestForAssistants
    if courseName
      filteredRequestForAssistants = filteredRequestForAssistants.filter (requestForAssistant) ->
        textIsInSearch requestForAssistant.courseName, courseName, true, true
    console.log filteredRequestForAssistants
    if studentName
      filteredRequestForAssistants = filteredRequestForAssistants.filter (requestForAssistant) ->
        textIsInSearch requestForAssistant.studentName, studentName, true, true
    console.log filteredRequestForAssistants
    if ~term
      filteredRequestForAssistants = filteredRequestForAssistants.filter (requestForAssistant) ->
        requestForAssistant.termId is term
    console.log filteredRequestForAssistants
    if ~isTrained
      filteredRequestForAssistants = filteredRequestForAssistants.filter (requestForAssistant) ->
        requestForAssistant.isTrained is !isTrained
    console.log filteredRequestForAssistants
    if ~status
      filteredRequestForAssistants = filteredRequestForAssistants.filter (requestForAssistant) ->
        textIsInSearch requestForAssistant.status, status, true, true
    view.setData filteredRequestForAssistants.sort (a, b) -> compare a.id, b.id
    console.log filteredRequestForAssistants

  state.all ['requestForAssistants', 'offerings', 'persons', 'courses'], ([_requestForAssistants, offerings, persons, courses]) ->
    requestForAssistants = _requestForAssistants.map (requestForAssistant) ->
      offering = (offerings.filter ({id}) -> String(id) is String requestForAssistant.offeringId)[0]
      extend {}, requestForAssistant,
        professorName: (persons.filter ({id}) -> String(id) is String offering.professorId)[0]?.fullName ? ''
        studentName: (persons.filter ({id}) -> String(id) is String offering.studentId)[0]?.fullName ? ''
        courseName: (courses.filter ({id}) -> String(id) is String offering.courseId)[0]?.name ? ''
    update()

  onEvent [
    professorNameInput
    courseNameInput
    studentNameInput
    termDropdown.input
    isTrainedDropdown.input
    statusDropdown.input
  ], ['input', 'pInput'], update

  view