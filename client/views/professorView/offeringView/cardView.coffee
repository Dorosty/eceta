# IMPROVEMENT: rewrite to use `collection`
component = require '../../../utils/component'
{extend, remove} = require '../../../utils'

module.exports = component 'professorOfferingsCardView', ({dom, events, state, returnObject}, {changeRequestForAssistant}) ->
  {E, text, append, empty, setStyle} = dom
  {onEvent} = events

  offering = undefined
  courses = chores = []

  view = E()

  update = ->
    empty view
    append view, offering.requestForAssistants.map (requestForAssistant) ->
      E class: "panel panel-#{if requestForAssistant.status is 'تایید شده' then 'success' else if requestForAssistant.status is 'رد شده' then 'danger' else 'info'}",
        E class: 'panel-heading',
          E float: 'left',
            unless requestForAssistant.isClosed
              E class: 'btn-group btn-group-xs',
                [
                  {status: 'تایید شده', klass: 'success'}
                  {status: 'رد شده', klass: 'danger'}
                  {status: 'در حال بررسی', klass: 'info'}
                ].map ({status, klass}) ->
                  button = E 'button', class: 'btn btn-' + (if status is requestForAssistant.status then klass else 'default'), status
                  onEvent button, 'click', (e) ->
                    unless status is 'تایید شده'
                      requestForAssistant.chores = []
                      requestForAssistant.isChiefTA = false
                    extend requestForAssistant, {status}
                    changeRequestForAssistant requestForAssistant
                  button
              E float: 'left', marginLeft: 10, 'تغییر وضعیت درخواست:'
          E 'h3', class: 'panel-title', fontWeight: 'bold',
            text "#{fullName} ("
            E 'a', cursor: 'pointer', fontWeight: 'lighter', fontSize: 13, target: '_blank', href: "mailto:#{requestForAssistant.email}", requestForAssistant.email
            text ')'
        body = E class: 'panel-body',
          E class: 'col-md-5',
            E 'ul', null,
              offering.requiredCourses.map (courseId) ->
                [course] = courses.filter ({id}) -> String(id) is String(courseId)
                [grade] = requestForAssistant.grades.filter ({courseId}) -> String(courseId) is String(course.id)
                E 'li', null, "نمره درس #{course.name}: #{if grade? then grade.grade else '(وارد نشده)'}"
              E 'li', null,
                E 'span', fontWeight: 'bold', "معدل کل: #{requestForAssistant.gpa}"
              E 'li', null, "مقطع: #{requestForAssistant.degree}"
              E 'li', null,
                text 'در کارگاه آموزش دستیاران آموزشی شرکت '
                E 'span', fontWeight: 'bold', color: (if requestForAssistant.isTrained then 'green' else 'red'), if requestForAssistant.isTrained then 'کرده است.' else 'نکرده است.'
          if requestForAssistant.message
            do ->
              border = E class: 'col-md-4', borderLeft: '1px dashed #AAA', borderRight: '1px dashed #AAA',
                [
                  E fontWeight: 'bold', marginBottom: 10, 'پیام دانشجو: '
                  E 'span', null, requestForAssistant.replace '\n', '<br />'
                ]
              setTimeout ->
                setStyle border, height: body.offsetHeight - 30
              border
          E class: 'col-md-3',
            if requestForAssistant.status is 'تایید شده' 
              [
                E class: 'checkbox',
                  E 'label', null,
                    do ->
                      checkbox = E 'input', type: 'checkbox', cursor: 'pointer', checked: requestForAssistant.isChiefTA
                      onEvent checkbox, 'change', ->
                        if requestForAssistant.isClosed
                          return setStyle checkbox, checked: !checkbox.checked
                        requestForAssistant.isChiefTA = checkbox.checked
                        changeRequestForAssistant requestForAssistant
                      checkbox
                    text 'دستیار اصلی است.'
                E 'span', fontWeight: 'bold', 'وظایف:'
                E class: 'well well-sm',
                  chores.map ({id, persianName}) ->
                    E class: 'checkbox',
                      E 'label', null,
                        do ->
                          checkbox = E 'input', type: 'checkbox', cursor: 'pointer', checked: requestForAssistant.chores.some (choreId) -> String(choreId) is String(id)
                          onEvent checkbox, 'change', ->
                            if requestForAssistant.isClosed
                              return setStyle checkbox, checked: !checkbox.checked
                            remove requestForAssistant.chores, id
                            if checkbox.checked
                              requestForAssistant.chores.push id
                            changeRequestForAssistant requestForAssistant
                          checkbox
                        text persianName
              ]

  state.all ['courses', 'chores'], ([_courses, _chores]) ->
    courses = _courses
    chores = _chores
    update()

  returnObject
    update: (_offering) ->
      offering = _offering
      update()

  view