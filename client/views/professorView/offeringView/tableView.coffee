component = require '../../../utils/component'
table = require '../../../components/table'
{document, body} = require '../../../utils/dom'

module.exports = component 'professorOfferingsTableView', ({dom, events, state, returnObject}, {changeRequestForAssistant}) ->
  {E, text, setStyle, append, empty} = dom
  {onEvent} = events

  offering = tableInstance = undefined
  courses = chores = hidePopovers = []
  popoverOpen = false

  view = E 'span'

  update = ->
    hidePopovers.forEach (x) -> x()
    empty view
    unless offering
      return
    append view, tableInstance = table
      properties:
        notStriped: true
      headers: [
        name: 'نام', key: 'fullName'
      ].concat(offering.requiredCourses.map (courseId) ->
        [course] = courses.filter ({id}) -> String(id) is String(courseId)
        {
          name: "نمره درس #{course.name}"
          getValue: (requestForAssistant) ->
            [course] = courses.filter ({id}) -> String(id) is String(courseId)
            [grade] = requestForAssistant.grades.filter ({courseId}) -> String(courseId) is String(course.id)
            if grade?
              grade.grade
            else
              -1
        }
      ).concat([
        {name: 'معدل کل', key: 'gpa'}
        {name: 'مطقع', key: 'degree'}
        {
          name: 'در کارگاه آموزش دستیاران آموزشی شرکت کرده است'
          key: 'isTrained'
          styleTd: (requestForAssistant, td, offs) ->
            setStyle td, textAlign: 'center', text: ''
            append td, checkbox = E 'input', type: 'checkbox', checked: requestForAssistant.isTrained
            offs.push onEvent checkbox, 'change', ->
              setStyle checkbox, checked: !checkbox.checked
        }
        {
          name: 'پیام دانشجو'
          styleTd: (requestForAssistant, td, offs) ->
            setStyle td, textAlign: 'center'
            if message
              append td, messageIcon = E class: 'fa fa-envelope'
              $(messageIcon).tooltip
                html: true
                placement: 'right'
                trigger: 'manual'
                template: '<div class="tooltip" role="tooltip"><div class="tooltip-arrow"></div><div class="tooltip-inner" style="font-size: 15px"></div></div>'
                title: requestForAssistant.message.replace '\n', '<br />'
              visible = false
              offs.push onEvent E(body), 'mousemove', (e) ->
                element = e.target
                while element isnt E(body).fn.element and element isnt td.fn.element
                  element = element.parentNode
                if element is td.fn.element and not visible
                  $(messageIcon).tooltip 'show'
                  visible = true
                if element isbt td.fn.element and visible
                  $(messageIcon).tooltip 'hide'
                  visible = false
              offs.push onMouseOut null, ->
                if visible
                  $(messageIcon).tooltip 'hide'
                visible = false

        }
      ]).concat (if offering.isClosed
          []
        else
          [
            name: 'تایید / رد'
            key: 'status'
            styleTd: (requestForAssistant, td, offs) ->
              changeStatus = td
              setStyle changeStatus, cursor: 'pointer',
              append changeStatus, E class: 'btn btn-default', cursor: 'pointer', 'تایید / رد'

              $(changeStatus).popover
                title: 'تایید / رد'
                trigger: 'manual'
                html: true
                container: 'body'
                content: do ->
                  showHideExtras = ->
                    if requestForAssistant.status is 'تایید شده'
                      show extras
                    else
                      hide extras
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
                        setStyle td, text: status
                        showHideExtras()
                      button      
                  extras = [
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
              hidePopovers.push ->
                $(changeStatus).popover 'hide'
              offs.push onEvent changeStatus, 'click', ->
                $(changeStatus).popover 'show'
              offs.push onEvent E(document), 'click', (e) ->
                element = e.target
                while element isnt null and element isnt document.body
                  if element is changeStatus or ~(element.getAttribute?('class') or '').indexOf 'popover'
                    return
                  element = element.parentNode
                $(changeStatus).popover 'hide'
          ]
      )
    tableInstance.setData offering.requestForAssistants

  state.all ['courses', 'chores'], ([_courses, _chores]) ->
    courses = _courses
    chores = _chores
    update()

  returnObject
    update: (_offering) ->
      if not offering or _offering.id is offering.id and JSON.stringify(_offering.requiredCourses) is JSON.stringify(offering.requiredCourses) and _offering.isClosed is offering.isClosed
        unless popoverOpen
          tableInstance?.setData offering.requestForAssistants
        return
      offering = _offering
      update()

  view