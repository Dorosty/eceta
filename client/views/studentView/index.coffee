component = require '../../utils/component'
requestForAssistant = require './requestForAssistant'
modal = require '../../singletons/modal'
table = require '../../components/table'
stateSyncedDropdown = require '../../components/dropdown/stateSynced'
searchBoxStyle = require '../../../components/table/searchBoxStyle'
{extend, textIsInSearch, compare} = require '../../utils'

module.exports = component 'studentView', ({dom, events, state, service, others}) ->
  {E, setStyle, show, hide} = dom
  {onEvent} = events
  {loading} = others

  service.getTerms()
  service.getOfferings()
  service.getCourses()
  service.getProfessors()
  service.getStudentRequestForAssistants()

  requestForAssistantPage = E requestForAssistant

  termDropdown = E stateSyncedDropdown,  
    stateName: 'terms'
    selectedIdStateName: 'currentTerm'
  termDropdown.showEmpty true
  setStyle termDropdown, searchBoxStyle.font
  setStyle termDropdown.input, searchBoxStyle.input

  courseNameInput = E 'input', searchBoxStyle.textbox
  courseNameInput = E 'input', searchBoxStyle.textbox

  selectedEntities = []
  deleteButton = do ->
    E class: 'btn btn-danger'
    onEvent deleteButton, 'click', ->
      modal.instance.display
        contents: E 'p', null," آیا از حذف این #{selectedEntities.length} درخواست اطمینان دارید؟"
        submitText: 'حذف'
        submitType: 'danger'
        closeText: 'انصراف'
        submit: ->
          tableInstance.cover()
          service.deleteRequestForAssistants selectedEntities.map ({entity}) -> entity.id
          .fin -> tableInstance.uncover()
          modal.instance.hide()

  view = [
    noData = E null, 'در حال بارگزاری...'
    yesData = E null,
      E marginTop: 30,
        deleteButton
        yourRequests = E class: 'panel panel-success',
          E class: 'panel-heading',
            E 'h3', class: 'panel-title', 'درخواست‌های ارسال شده توسط شما در این ترم'
          setntTable = table {
            properties:
              multiSelect: true
            headers: [
              {name: 'نام درس', key: 'courseName'}
              {name: 'نام استاد', key: 'professorName'}
            ]
            hanlders:
              select: (offering) -> requestForAssistantPage.edit offering
              update: (entities) ->
                selectedEntities = entities.filter ({selected}) -> selected
                  if selectedEntities.length
                    show deleteButton
                    setStyle deleteButton, text: "حذف #{selectedEntities.length} درخواست انتخاب شده"
                  else
                    hide deleteButton
          }
      E class: 'panel panel-info',
        E class: 'panel-heading',
          E 'h3', class: 'panel-title', 'لیست فراخوان‌ها'
        offeringsTable = table {
          headers: [
            {name: 'نام درس', key: 'courseName', searchBox: courseNameInput}
            {name: 'نام استاد', key: 'professorName', searchBox: professorNameInput}
            {name: 'ترم', key: 'termId', searchBox, termDropdown}
          ]
          hanlders:
            select: (offering) -> requestForAssistantPage.send offering
        }
  ]

  loading ['terms', 'offerings', 'courses', 'professors', 'requestForAssistants'], yesData, noData

  state.all ['offerings', 'courses', 'professors', 'requestForAssistants'], ([offerings, courses, professors, requestForAssistants]) ->

    offerings = offerings.map (offering) ->
      extend {}, offering,
        courseName: (courses.filter ({id}) -> String(id) is String(offering.courseId))[0]?.name ? ''
        professorName: (professors.filter ({id}) -> String(id) is String(offering.professorId))[0]?.fullName ? ''
        requestForAssistant: (requestForAssistants.filter ({offeringId}) -> String(offeringId) is String(offering.id))[0]
        requiredCourses: offering.requiredCourses.map (courseId) -> id: courseId, name: (courses.filter ({id}) -> String(id) is String(courseId))[0]?.name ? ''

    courseName = courseNameInput.value()
    professorName = professorNameInput.value()
    term = termDropdown.value()
    filteredOfferings = offerings.filter ({isClosed, requestForAssistant}) -> not isClosed and not requestForAssistant
    if courseName
      filteredOfferings = filteredOfferings.filter (offering) -> textIsInSearch offering.courseName, courseName
    if professorName
      filteredOfferings = filteredOfferings.filter (offering) -> textIsInSearch offering.professorName, professorName
    if ~term
      filteredOfferings = filteredOfferings.filter (offering) -> textIsInSearch offering.termId, term
    offeringsTable.setData filteredOfferings

    setntTable.setData sent = offerings.filter ({requestForAssistant}) -> requestForAssistant

    if sent.length
      show yourRequests
    else
      hide yourRequests

  view