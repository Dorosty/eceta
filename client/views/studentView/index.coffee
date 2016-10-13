component = require '../../utils/component'
requestForAssistant = require './requestForAssistant'
modal = require '../../singletons/modal'
table = require '../../components/table'
stateSyncedDropdown = require '../../components/dropdown/stateSynced'
searchBoxStyle = require '../../components/table/searchBoxStyle'
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

  view = [
    noData = E null, 'در حال بارگزاری...'
    yesData = E null,
      E marginTop: 30,
        yourRequests = E class: 'panel panel-success',
          E class: 'panel-heading',
            E 'h3', class: 'panel-title', 'درخواست‌های ارسال شده توسط شما در این ترم'
          setntTable = table {
            headers: [
              {name: 'نام درس', key: 'courseName'}
              {name: 'نام استاد', key: 'professorName'}
            ]
            hanlders:
              select: (offering) -> requestForAssistantPage.edit offering
          }
      E class: 'panel panel-info',
        E class: 'panel-heading',
          E 'h3', class: 'panel-title', 'لیست فراخوان‌ها'
        offeringsTable = table {
          headers: [
            {name: 'نام درس', key: 'courseName', searchBox: courseNameInput}
            {name: 'نام استاد', key: 'professorName', searchBox: professorNameInput}
            {name: 'ترم', key: 'termId', searchBox, termDropdown}
            {
              name: 'حذف'
              styleTd: (offering, td, offs) ->
                setStyle td, color: 'red', width: 100
                offs.push onEvent td, 'click', ->
                  modal.instance.display
                    contents: E 'p', null," آیا از حذف این #{selectedEntities.length} درخواست اطمینان دارید؟"
                    submitText: 'حذف'
                    submitType: 'danger'
                    closeText: 'انصراف'
                    submit: ->
                      tableInstance.cover()
                      service.deleteRequestForAssistants [offering.id]
                      .fin -> tableInstance.uncover()
                      modal.instance.hide()
            }
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