component = require '../../utils/component'
offeringsView = require './offeringsView'
{extend} = require '../../utils'

module.exports = component 'profesorView', ({dom, events, state, service}) ->
  {E, append, empty, addClass, removeClass, hide, show, loading} = dom
  {onEvent} = events

  service.getProfessorOfferings()
  service.getCourses()
  service.getChores()

  view = E null,
    noData = E null, 'در حال بارگزاری...'
    yesData = E position: 'relative',
      E class: 'col-md-3', marginTop: 40,
        E class: 'panel panel-default',
          E class: 'panel-heading',
            E class: 'panel-title', 'لیست درس‌های شما'
          offeringsList = E class: 'list-group'
      hide offeringView = offeringsViewInstance = E offeringsView

  offerings = selectedOfferingId = undefined

  handleSelectedOffering = ->
    return unless selectedOfferingId?
    show offeringView
    offeringsViewInstance.update offerings.filter ({id}) -> String(id) is String(selectedOfferingId)[0]

  handleOfferings = ->
    empty offeringsList
    append offeringsList, offerings.map ({id, courseName, requestForAssistants, isClosed}) ->
      count = requestForAssistants.length
      element = E 'li', cursor: 'pointer', class: 'list-group-item',
        E 'span', cursor: 'pointer', courseName
        E 'span', cursor: 'pointer', class: 'badge', color: 'white', backgroundColor: (if isClosed then '#008000' else '#ff7878'), if isClosed then 'نهایی شده' else count

      if String(id) is String(selectedOfferingId)
        addClass element, 'active'
      else
        removeClass element, 'active'

      onEvent element, 'click', ->
        selectedOfferingId = id
        handleOfferings()

      element
    
    handleSelectedOffering()

  loading ['offerings', 'courses', 'chores'], yesData, noData

  offState = state.all ['offerings', 'courses'], ([_offerings, courses]) ->
    offerings = _offerings.map (offering) ->
      extend {}, offering, courseName: (courses.filter ({id}) -> String(id) is String(offering.courseId))[0].name

    unless offeringsViewInstance.isEditing()
      handleOfferings()

  view