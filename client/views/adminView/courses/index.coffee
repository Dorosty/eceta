component = require '../../../utils/component'
crudPage = require '../crudPage'
credit = require './credit'
multiselect = require './multiselect'
searchBoxStyle = require '../../../components/table/searchBoxStyle'
numberInput = require '../../../components/restrictedInput/number'
{textIsInSearch} = require '../../../utils'

module.exports = component 'coursesView', ({dom, events, state, service}) ->
  {E, setStyle} = dom
  {onEvent} = events

  service.getCourses()
  service.getPersons()

  nameInput = E 'input', searchBoxStyle.textbox

  courseNumberInput = E numberInput, true
  setStyle courseNumberInput, searchBoxStyle.textbox

  view = E crudPage,
    entityName: 'درس'
    requiredStates: ['courses', 'professors']
    extraButtonsBefore: multiselectInstance = E multiselect, (callback) -> view.setSelectedRows callback
    headers: [
      {name: 'نام درس', key: 'name', searchBox: nameInput}
      {name: 'شماره درس', key: 'number', searchBox: courseNumberInput}
    ]
    onTableUpdate: (descriptors) ->
      multiselectInstance.setChecked descriptors
    credit: E(credit).credit
    deleteItems: (courses) -> service.deleteCourses courses.map ({id}) -> id

  courses = []
  update = ->
    name = nameInput.value()
    number = courseNumberInput.value()
    filteredCourses = courses
    if name
      filteredCourses = filteredCourses.filter (course) -> textIsInSearch course.name, name
    if number
      filteredCourses = filteredCourses.filter (course) -> textIsInSearch course.number, number
    view.setData filteredCourses

  state.courses.on (_courses) ->
    courses = _courses
    update()

  onEvent [nameInput, courseNumberInput], ['input', 'pInput'], update

  view