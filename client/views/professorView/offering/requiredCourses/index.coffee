component = require '../../../../utils/component'
style = require './style'

module.exports = component 'professorOfferingViewRequiredCourses', ({dom, events, service, returnObject}) ->
  {E, setStyle, empty, append, show, hide} = dom
  {onEvent} = events

  view = [
    E 'h4', fontWeight: 'bold', display: 'inline-block', 'لیست دروس مرتبط'
    E 'span', null, ' (درس‌هایی که دانشجو موظف است نمره خود را در آنها اعلام کند)'
    E margin: '10px 0 60px', position: 'relative',
      requiredCoursesList = E()        
      addCourse = E style.addCourse
        E 'span', style.courseAdorner, '+ '
        E 'span', cursor: 'pointer', 'افزودن درس'
      cover = E position: 'absolute', top: 0, left: 0, right: 0, bottom: 0, background: 'white', transition: '0.5s'
  ]

  doCover = ->
    setStyle cover, opacity: 0.5, visibility: 'visible'
  do doUncover = ->
    setStyle cover, opacity: 0, visibility: 'hidden'

  addCourseDropdown = dropdown 
    getId: (course) -> String course.id)
    getTitle: (course) -> course.name
  addCourseDropdown.showEmpty true
  addCourseDropdownId = generateId()
  setStyle addCourseDropdown.input, id: addCourseDropdownId

  onEvent addCourseDropdown.input, ['input', 'pInput'], ->
    modal.instance.setEnabled ~addCourseDropdown.value()
    
  offering = undefined

  onEvent addCourse, 'click', ->
    modal.instance.display
      autoHide: true
      title: 'افزودن درس'
      submitText: 'افزودن'
      contents: E class: 'form-group',
        E 'label', for: id = addCourseDropdownId, 'شماره دانشجویی / پرسنلی'
        addCourseDropdown
      submit: ->
        service.addRequiredCourse
          courseId: addCourseDropdown.element.value
          offeringId: offering.id

  returnObject
    update: (_offering) ->
      offering = _offering
      empty requiredCoursesList
      append requiredCoursesList, offering.requiredCourses.map (courseId) ->
        {name} = getCourse courseId
        course = E style.course,
          unless offerin.isClosed
            x = E 'span', style.courseX, '× '
          E 'span', null, name
        onEvent x, 'click', ->
          doCover()
          service.removeRequiredCourse {courseId, offeringId: offering.id}
          .fin doUncover
        course
      if offering.isClosed
        hide addCourse
      else
        show addCourse

  view