crudPage = require './crudPage'
creditCourse = require './credit/course'
state = require '../../state'
service = require '../../service'
numberInput = require '../../components/numberInput'
{toPersian} = require '../../utils'
{E, setStyle} = require '../../utils/dom'

exports.createElement = ->

  service.getCourses()
  service.getOfferings()
  service.getPersons()
  service.getTerms()

  componentState = {} # dataGetterCallback
  elements = {} # element, credit, page
  offs = [] # {courses}, {credit}

  elements.credit = creditCourse.createElement()
  offs.push elements.credit.off

  elements.page = crudPage.createElement
    entityName: 'درس'
    headerNames: ['نام درس', 'شماره درس']
    itemKeys: ['name', 'number']
    credit: elements.credit.show
    requiredStates: ['courses', 'offerings', 'professors', 'terms']
    onDataGetter: (callback) -> componentState.dataGetterCallback = callback
    deleteItem: (course) -> service.deleteCourse course.id
    searchBoxes: [
      E 'input', class: 'form-control', marginTop: 20, fontWeight: 'normal', placeholder: 'جستجو...'
      setStyle numberInput.createElement().element, class: 'form-control', marginTop: 20, fontWeight: 'normal', placeholder: 'جستجو...'
    ]

  elements.element = elements.page.element
  offs.push elements.page.off

  offs.push state.courses.on (courses) ->
    componentState.dataGetterCallback ([name, number]) ->
      filteredCourses = courses
      if name
        filteredCourses = filteredCourses.filter (course) -> ~toPersian(course.name).toLowerCase().indexOf name
      if number
        filteredCourses = filteredCourses.filter (course) -> ~toPersian(course.number).toLowerCase().indexOf number
      filteredCourses.sort (a, b) -> b.id - a.id

  element: elements.element
  off: ->
    offs.forEach (x) -> x()
    offs = []