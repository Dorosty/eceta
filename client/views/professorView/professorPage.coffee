
professorOfferingView = require './professorOfferingView'

offState = offCourseDropdown = undefined

module.exports = 
  off: ->
    offState?()
    offCourseDropdown?()
    professorOfferingView.off?()
  createElement: ->
    {E, append, empty, bindEvent, addClass, removeClass, hide, show, loading, toPersian} = require './utils'
    state = require './state'
    service = require './service'

    view = E null,
      noData = E null, 'در حال بارگزاری...'
      yesData = E position: 'relative',
        E class: 'col-md-3', marginTop: 40,
          E class: 'panel panel-default',
            E class: 'panel-heading',
              E class: 'panel-title', 'لیست درس‌های شما'
            offeringsList = E class: 'list-group'
        hide offeringView = professorOfferingView.createElement()

    person = courses = selectedOfferingId = undefined

    getCourse = (courseId) -> (courses.filter ({id}) -> String(id) is String(courseId))[0]

    handleSelectedOffering = ->
      return unless selectedOfferingId?
      show offeringView
      [offering] = person.offerings.filter ({id}) -> String(id) is String(selectedOfferingId)
      professorOfferingView.update offering

    handleOfferings = ->
      empty offeringsList
      append offeringsList, person.offerings.map ({id, courseId, requestForAssistants, isClosed}) ->
        {name} = getCourse courseId
        count = requestForAssistants.length
        element = E 'li', cursor: 'pointer', class: 'list-group-item',
          E 'span', cursor: 'pointer', toPersian name
          E 'span', cursor: 'pointer', class: 'badge', color: 'white', backgroundColor: (if isClosed then '#008000' else '#ff7878'), if isClosed then 'نهایی شده' else toPersian count or ''

        if String(id) is String(selectedOfferingId)
          addClass element, 'active'
        else
          removeClass element, 'active'

        bindEvent element, 'click', ->
          selectedOfferingId = id
          handleOfferings()

        return element
      
      handleSelectedOffering()

    loading ['person', 'courses', 'chores'], yesData, noData

    offState = state.all ['person', 'courses'], ([_person, _courses]) ->
      [person, courses] = [_person, _courses]
      unless professorOfferingView.isEditingCards()
        handleOfferings()

    return view
