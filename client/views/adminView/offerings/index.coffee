component = require '../../../utils/component'
crudPage = require '../crudPage'
credit = require './credit'
multiselect = require './multiselect'
extras = require './extras'
searchBoxStyle = require '../../../components/table/searchBoxStyle'
dropdown = require '../../../components/dropdown'
stateSyncedDropdown = require '../../../components/dropdown/stateSynced'
{extend, textIsInSearch} = require '../../../utils'

module.exports = component 'offeringsView', ({dom, events, state, service}, {goToRequestForAssistants}) ->
  {E, setStyle} = dom
  {onEvent} = events

  service.getOfferings()
  service.getCourses()
  service.getPersons()
  # service.getTerms()
  service.getCurrentTerm()
  service.getRequestForAssistants()

  termDropdown = E stateSyncedDropdown,
    stateName: 'terms'
    selectedIdStateName: 'currentTerm'
  setStyle termDropdown, searchBoxStyle.font
  setStyle termDropdown.input, searchBoxStyle.input
  termDropdown.showEmpty true

  isClosedDropdown = E dropdown, getTitle: (x) ->
    switch x
      when 0
        'نهایی نشده'
      when 1
        'نهایی شده'
  setStyle isClosedDropdown, searchBoxStyle.font    
  setStyle isClosedDropdown.input, searchBoxStyle.input
  isClosedDropdown.showEmpty true
  isClosedDropdown.update [0, 1]

  courseNameInput = E 'input', searchBoxStyle.textbox
  professorNameInput = E 'input', searchBoxStyle.textbox

  view = E crudPage,
    entityName: 'فراخوان'
    requiredStates: ['offerings', 'courses', 'professors', 'terms', 'currentTerm', 'requestForAssistants']
    extraButtonsBefore: multiselectInstance = E multiselect, (callback) -> view.setSelectedRows callback
    extraButtons: extrasInstance = E extras, goToRequestForAssistants
    headers: [
      {name: 'نام درس', key: 'courseName', searchBox: courseNameInput}
      {name: 'نام استاد', key: 'professorName', searchBox: professorNameInput}
      {name: 'ترم', key: 'termId', searchBox: termDropdown}
      {
        name: 'وضعیت'
        searchBox: isClosedDropdown
        getValue: (offering) ->
          if offering.isClosed
            'نهایی شده'
          else
            'نهایی نشده'
        styleTd: (offering, td) ->
          if offering.isClosed
            setStyle td, color: 'green'
          else
            setStyle td, color: 'red'
      }
      {name: 'ظرفیت', key: 'capacity'}
      {
        name: 'تعداد درخواست'
        notClickable: true
        key: 'requestForAssistantsCount'
        styleTd: (offering, td, offs) ->
          if offering.requestForAssistantsCount
            setStyle td, color: 'blue', text: "مشاهده #{offering.requestForAssistantsCount} درخواست"
            offs.push onEvent td, 'click', -> goToRequestForAssistants [offering.id]
          else
            setStyle td, color: 'gray', text: 'بدون درخواست'
      }
    ]
    onTableUpdate: (descriptors) ->
      multiselectInstance.setChecked descriptors
      extrasInstance.update descriptors
    credit: E(credit).credit
    deleteItems: (offerings) ->
      service.deleteOfferings offerings.map ({id}) -> id

  offerings = []
  update = ->
    courseName = courseNameInput.value()
    professorName = professorNameInput.value()
    term = termDropdown.value()
    isClosed = isClosedDropdown.value()
    filteredOfferings = offerings
    if courseName
      filteredOfferings = filteredOfferings.filter (offering) -> textIsInSearch offering.courseName, courseName
    if professorName
      filteredOfferings = filteredOfferings.filter (offering) -> textIsInSearch offering.professorName, professorName
    if ~term
      filteredOfferings = filteredOfferings.filter (offering) -> textIsInSearch offering.termId, term
    if ~isClosed
      filteredOfferings = filteredOfferings.filter (offering) -> offering.isClosed is !!isClosed
    view.setData filteredOfferings

  state.all ['offerings', 'courses', 'professors', 'requestForAssistants'], ([_offerings, courses, professors, requestForAssistants]) ->
    offerings = _offerings.map (offering) ->
      extend {}, offering,
        courseName: (courses.filter ({id}) -> String(id) is String(offering.courseId))[0]?.name ? ''
        professorName: (professors.filter ({id}) -> String(id) is String(offering.professorId))[0]?.fullName ? ''
        requestForAssistantsCount: (requestForAssistants.filter ({offeringId}) -> String(offeringId) is String(offering.id)).length
    update()

  onEvent [courseNameInput, professorNameInput, termDropdown.input, isClosedDropdown.input], ['input', 'pInput'], update

  view