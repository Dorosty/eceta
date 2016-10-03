component = require '../../../utils/component'
crudPage = require '../crudPage'
credit = require './credit'
multiselect = require './multiselect'
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
        key: 'isTrainedString'
        searchBox: isTrainedDropdown
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
    extraButtonsBefore: do ->
      selectMultipleGroup = E class: 'btn-group', marginLeft: 10,
        selectMultipleButton = E class: 'btn btn-default dropdown-toggle',
          E 'span', class: 'caret'
          selectMultipleCheckbox = E 'input', type: 'checkbox', marginRight: 10, position: 'relative', top: 3
        selectMultipleList = E 'ul', class: 'dropdown-menu',
          l0 = E 'li', null, E 'a', null, 'انتخاب همه'
          l1 = E 'li', null, E 'a', null, 'انتخاب هیچ'
          E 'li', class: 'divider'
          l2 = E 'li', null, E 'a', null, 'انتخاب درخواست‌های در حال بررسی'
          l3 = E 'li', null, E 'a', null, 'انتخاب درخواست‌های تایید شده'
          l4 = E 'li', null, E 'a', null, 'انتخاب درخواست‌های رد شده'
          E 'li', class: 'divider'
          l5 = E 'li', null, E 'a', null, 'انتخاب درخواست‌های کارگاه رفته'
          l6 = E 'li', null, E 'a', null, 'انتخاب درخواست‌های کارگاه نرفته'
      onEvent selectMultipleButton, 'click', selectMultipleCheckbox, ->
        addClass selectMultipleGroup, 'open'
      onEvent [E(body)], 'click', [selectMultipleButton, selectMultipleList], ->
        removeClass selectMultipleGroup, 'open'
      onEvent [l0, l1, l2, l3, l4, l5, l6], 'click', ->
        removeClass selectMultipleGroup, 'open'
      onEvent selectMultipleCheckbox, 'change', ->
        view.setSelectedRows (rows) -> if selectMultipleCheckbox.checked() then rows else []
      onEvent l0, 'click', ->
        view.setSelectedRows (rows) -> rows
        setStyle selectMultipleCheckbox, checked: true
      onEvent l1, 'click', ->
        view.setSelectedRows (rows) -> []
        setStyle selectMultipleCheckbox, checked: false
      onEvent l2, 'click', ->
        view.setSelectedRows (rows) -> rows.filter ({entity}) -> entity.status is 'در حال بررسی'
        setStyle selectMultipleCheckbox, checked: false
      onEvent l3, 'click', ->
        view.setSelectedRows (rows) -> rows.filter ({entity}) -> entity.status is 'تایید شده'
        setStyle selectMultipleCheckbox, checked: false
      onEvent l4, 'click', ->
        view.setSelectedRows (rows) -> rows.filter ({entity}) -> entity.status is 'رد شده'
        setStyle selectMultipleCheckbox, checked: false
      onEvent l5, 'click', ->
        view.setSelectedRows (rows) -> rows.filter ({entity}) -> entity.isTrained
        setStyle selectMultipleCheckbox, checked: false
      onEvent l6, 'click', ->
        view.setSelectedRows (rows) -> rows.filter ({entity}) -> !entity.isTrained
        setStyle selectMultipleCheckbox, checked: false
      selectMultipleGroup
    extraButtons: [
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
    ]
    onTableUpdate: (entities) ->
      selectedEntities = entities.filter ({selected}) -> selected
      if selectedEntities.length
        show sendEmailToStudents
        show sendEmailToProfessors
        studentsCount = Object.keys(selectedEntities.reduce ((acc, {entity}) ->
          acc[entity.studentId] ?= 0
          acc[entity.studentId]++
          acc
        ), {}).length
        setStyle sendEmailToStudents, text: "ارسال ایمیل به #{studentsCount} دانشجو انتخاب شده"
        professorsCount = Object.keys(selectedEntities.reduce ((acc, {entity}) ->
          acc[entity.professorId] ?= 0
          acc[entity.professorId]++
          acc
        ), {}).length
        setStyle sendEmailToProfessors, text: "ارسال ایمیل به #{professorsCount} استاد انتخاب شده"
      else
        hide sendEmailToStudents
        hide sendEmailToProfessors
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
    if offeringIds
      filteredRequestForAssistants = filteredRequestForAssistants.filter (requestForAssistant) ->
        String(requestForAssistant.offeringId) in offeringIds.map (offeringId) -> String offeringId
    if professorName
      filteredRequestForAssistants = filteredRequestForAssistants.filter (requestForAssistant) ->
        textIsInSearch requestForAssistant.professorName, professorName, true, true
    if courseName
      filteredRequestForAssistants = filteredRequestForAssistants.filter (requestForAssistant) ->
        textIsInSearch requestForAssistant.courseName, courseName, true, true
    if studentName
      filteredRequestForAssistants = filteredRequestForAssistants.filter (requestForAssistant) ->
        textIsInSearch requestForAssistant.studentName, studentName, true, true
    if ~term
      filteredRequestForAssistants = filteredRequestForAssistants.filter (requestForAssistant) ->
        requestForAssistant.termId is term
    if ~isTrained
      filteredRequestForAssistants = filteredRequestForAssistants.filter (requestForAssistant) ->
        requestForAssistant.isTrained is !isTrained
    if ~status
      filteredRequestForAssistants = filteredRequestForAssistants.filter (requestForAssistant) ->
        textIsInSearch requestForAssistant.status, status, true, true
    view.setData filteredRequestForAssistants.sort (a, b) -> compare a.id, b.id

  state.all ['requestForAssistants', 'persons', 'courses'], ([_requestForAssistants, persons, courses]) ->
    requestForAssistants = _requestForAssistants.map (requestForAssistant) ->
      extend {}, requestForAssistant,
        professorName: (persons.filter ({id}) -> String(id) is String requestForAssistant.professorId)[0]?.fullName ? ''
        studentName: (persons.filter ({id}) -> String(id) is String requestForAssistant.studentId)[0]?.fullName ? ''
        courseName: (courses.filter ({id}) -> String(id) is String requestForAssistant.courseId)[0]?.name ? ''
        isTrainedString: if requestForAssistant.isTrained then 'بله' else 'خیر'
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