component = require '../../../utils/component'
table = require '../../../components/table'
{extend, remove} = require '../../../utils'
{document, body} = require '../../../utils/dom'

module.exports = component 'professorOfferingsTableView', ({dom, events, state, returnObject}, {changeRequestForAssistant}) ->
  {E, text, setStyle, append, empty, show, hide} = dom
  {onEvent, onMouseout} = events

  offering = tableInstance = undefined
  courses = chores = hidePopovers = []
  tooltipOpens = {}
  popoverOpens = {}

  view = E 'span'

  update = ->
    unless offering
      return
    hidePopovers.forEach (x) -> x()
    tooltipOpens = {}
    popoverOpens = {}
    empty view
    append view, tableInstance = table
      properties:
        notStriped: true
      styleRow: (requestForAssistant, tr) ->
        setStyle tr, backgroundColor: (if requestForAssistant.status is 'تایید شده' then '#E5FFE5' else if requestForAssistant.status is 'رد شده' then '#E5E5E5' else 'white')
      headers: [
        name: 'نام', key: 'fullName'
      ].concat(offering.requiredCourses.map (courseId) ->
        [course] = courses.filter ({id}) -> String(id) is String(courseId)
        {
          name: "نمره درس #{course.name}"
          getValue: (requestForAssistant) ->
            [grade] = requestForAssistant.grades.filter ({courseId}) -> String(courseId) is String(course.id)
            if grade?
              grade.grade
            else
              -1
          styleTd: (requestForAssistant, td) ->
            [grade] = requestForAssistant.grades.filter ({courseId}) -> String(courseId) is String(course.id)
            if grade?
              setStyle td, text: grade.grade
            else
              setStyle td, text: '(وارد نشده)'
        }
      ).concat([
        {name: 'معدل کل', key: 'gpa'}
        {name: 'مطقع', key: 'degree'}
        {
          name: 'در کارگاه آموزش دستیاران آموزشی شرکت کرده است'
          key: 'isTrained'
          styleTd: (requestForAssistant, td, offs) ->
            empty td
            setStyle td, textAlign: 'center', text: ''
            append td, checkbox = E 'input', type: 'checkbox', checked: requestForAssistant.isTrained
            offs.push onEvent checkbox, 'change', ->
              setStyle checkbox, checked: !checkbox.checked()
        }
        {
          name: 'پیام دانشجو'
          styleTd: (requestForAssistant, td, offs) ->
            setStyle td, textAlign: 'center'
            empty td
            if requestForAssistant.message
              append td, messageIcon = E class: 'fa fa-envelope'
              $(messageIcon.fn.element).tooltip
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
                  $(messageIcon.fn.element).tooltip 'show'
                  tooltipOpens[requestForAssistant.id] = true
                  visible = true
                if element isnt td.fn.element and visible
                  $(messageIcon.fn.element).tooltip 'hide'
                  tooltipOpens[requestForAssistant.id] = false
                  visible = false
              offs.push onMouseout null, ->
                if visible
                  $(messageIcon.fn.element).tooltip 'hide'
                  tooltipOpens[requestForAssistant.id] = false
                visible = false
        }
      ]).concat (if offering.isClosed
          []
        else
          [
            name: 'تایید / رد'
            key: 'status'
            styleTd: (requestForAssistant, td, offs, row) ->
              changeStatus = td
              empty changeStatus
              setStyle changeStatus, cursor: 'pointer', text: ''
              append changeStatus, E class: 'btn btn-default', cursor: 'pointer', 'تایید / رد'
              $(changeStatus.fn.element).popover 'destroy'
              setTimeout ->
                $(changeStatus.fn.element).popover
                  title: 'تایید / رد'
                  trigger: 'manual'
                  html: true
                  container: 'body'
                  content: do ->
                    content = E 'span', null,
                      E class: 'btn-group btn-group-xs',
                        buttons = [
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
                            setStyle buttons, class: 'btn btn-default'
                            setStyle button, class: 'btn btn-' + (if status is requestForAssistant.status then klass else 'default')
                            setStyle row.tr, backgroundColor: (if status is 'تایید شده' then '#E5FFE5' else if status is 'رد شده' then '#E5E5E5' else 'white')
                            showHideExtras()
                            $(changeStatus.fn.element).popover 'show'
                          button      
                      extras = [
                        E class: 'checkbox',
                          E 'label', null,
                            do ->
                              checkbox = E 'input', type: 'checkbox', cursor: 'pointer', checked: requestForAssistant.isChiefTA
                              onEvent checkbox, 'change', ->
                                if offering.isClosed
                                  return setStyle checkbox, checked: !checkbox.checked()
                                requestForAssistant.isChiefTA = checkbox.checked()
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
                                    if offering.isClosed
                                      return setStyle checkbox, checked: !checkbox.checked()
                                    remove requestForAssistant.chores, id
                                    if checkbox.checked()
                                      requestForAssistant.chores.push id
                                    changeRequestForAssistant requestForAssistant
                                  checkbox
                                text persianName
                      ]
                    do showHideExtras = ->
                      if requestForAssistant.status is 'تایید شده'
                        show extras
                      else
                        hide extras
                    content.fn.element
              hidePopovers.push ->
                $(changeStatus.fn.element).popover 'hide'
              offs.push onEvent changeStatus, 'click', ->
                $(changeStatus.fn.element).popover 'show'
                popoverOpens[requestForAssistant.id] = true
              offs.push onEvent E(document), 'click', (e) ->
                element = e.target
                while element isnt null and element isnt document.body
                  if element is changeStatus.fn.element or ~(element.getAttribute?('class') or '').indexOf 'popover'
                    return
                  element = element.parentNode
                $(changeStatus.fn.element).popover 'hide'
                popoverOpens[requestForAssistant.id] = false
          ]
      )
    tableInstance.setData offering.requestForAssistants

  somethingIsOpen = ->
    isOpen = false
    Object.keys(tooltipOpens).forEach (key) ->
      if tooltipOpens[key]
        isOpen = true
    Object.keys(popoverOpens).forEach (key) ->
      if popoverOpens[key]
        isOpen = true
    isOpen

  state.all ['courses', 'chores'], ([_courses, _chores]) ->
    courses = _courses
    chores = _chores
    unless somethingIsOpen()
      update()

  returnObject
    update: (_offering) ->
      prevOffering = offering
      offering = _offering
      if somethingIsOpen()
        return
      if prevOffering and offering.id is prevOffering.id and JSON.stringify(offering.requiredCourses) is JSON.stringify(prevOffering.requiredCourses) and offering.isClosed is prevOffering.isClosed
        tableInstance?.setData offering.requestForAssistants
        return
      update()

  view