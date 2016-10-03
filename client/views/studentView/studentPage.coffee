
requestForAssistant = require './requestForAssistant'

offTermDropdown = offState = undefined

module.exports =
  off: ->
    offTermDropdown?()
    offState?()
  createElement: ->
    {E, table, syncedDropdown, extend, show, hide, loading, toPersian} = require './utils'
    state = require './state'
    service = require './service'

    termDropdown = syncedDropdown
      getId: (term) -> term
      getTitle: (term) -> term
      dataState: 'terms'
      idState: 'currentTerm'
      onData: state.terms.on.bind null
      onId: state.terms.on.bind null
      showEmpty: true
      style: class: 'form-control', marginTop: 20, fontWeight: 'normal'

    offTermDropdown = termDropdown.off

    offeringsCallback = sentCallback = undefined

    view = [
      noData = E null, 'در حال بارگزاری...'
      yesData = E null,
        yourRequests = E class: 'panel panel-success',
          E class: 'panel-heading',
            E 'h3', class: 'panel-title', 'درخواست‌های ارسال شده توسط شما در این ترم'
          table {
            headerNames: ['نام درس', 'نام استاد']
            itemData: ['courseName', 'professorName']
            onData: (callback) -> sentCallback = callback
            onRowClick: requestForAssistant.bind null, true
            deleteItem: (requestForAssistant) -> service.deleteRequestForAssistant id: requestForAssistant.requestForAssistantId
            deleteText: 'آیا از حذف درخواست خود اطمینان دارید؟'
          }
        E class: 'panel panel-info',
          E class: 'panel-heading',
            E 'h3', class: 'panel-title', 'لیست فراخوان‌ها'
          table {
            headerNames: ['نام درس', 'نام استاد', 'ترم']
            itemData: ['courseName', 'professorName', 'termId']
            onData: (callback) -> offeringsCallback = callback
            onRowClick: requestForAssistant.bind null, false
            searchBoxes: [0..2].map (i) ->
              if i is 2
                termDropdown.element
              else
                E 'input', class: 'form-control', marginTop: 20, fontWeight: 'normal', placeholder: 'جستجو...'
          }
    ]


    offState = state.all ['offerings', 'courses', 'professors', 'person'], ([offerings, courses, professors, person]) ->

      offerings = offerings.map (offering) ->
        extend {}, offering,
          courseName: (courses.filter ({id}) -> +id is +offering.courseId)[0]?.name ? ''
          professorName: (professors.filter ({id}) -> +id is +offering.professorId)[0]?.fullName ? ''
          requiredCourses: offering.requiredCourses.map (courseId) -> id: courseId, name: (courses.filter ({id}) -> +id is +courseId)[0]?.name ? ''

      offeringsCallback ([courseName, professorName, term]) ->
        filteredOfferings = offerings.filter ({id, isClosed}) -> not (+id in person.requestForAssistants.map ({offeringId}) -> +offeringId) and not isClosed
        if courseName
          filteredOfferings = filteredOfferings.filter (offering) -> ~toPersian(offering.courseName).toLowerCase().indexOf courseName
        if professorName
          filteredOfferings = filteredOfferings.filter (offering) -> ~toPersian(offering.professorName).toLowerCase().indexOf professorName
        if term
          filteredOfferings = filteredOfferings.filter (offering) -> toPersian(offering.termId) is term
        filteredOfferings.sort (a, b) -> b.id - a.id

      sent = offerings.filter ({id}) -> +id in person.requestForAssistants.map ({offeringId}) -> +offeringId
      .map (offering) ->
        extend {}, offering,
          requestForAssistantId: (person.requestForAssistants.filter ({offeringId}) -> +offeringId is +offering.id)[0]?.id

      if sent.length
        show yourRequests
      else
        hide yourRequests

      sentCallback -> sent

    loading ['terms', 'offerings', 'courses', 'professors', 'person'], yesData, noData

    return view
    