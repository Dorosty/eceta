component = require '../../../utils/component'

module.exports = component 'professorOfferingsTableView', ({dom, events, returnObject}, {changeRequestForAssistant}) ->

      getTds = (requestForAssistant) ->
        {gpa, isTrained, message, fullName, email, degree, grades, chores, status} = requestForAssistant
        [
          E 'td', null, fullName
          requiredCourses.map (courseId) ->
            id = courseId
            [grade] = grades.filter ({courseId}) -> String(courseId) is String(id)
            E 'td', null, if grade? then grade.grade else '(وارد نشده)'
          E 'td', null, gpa
          E 'td', null, degree
          do ->
            td = E 'td', textAlign: 'center',
              checkbox = E 'input', type: 'checkbox', checked: isTrained
            onEvent checkbox, 'change', ->
              setStyle checkbox, checked: !checkbox.checked
            return td
          do ->
            td = E 'td', textAlign: 'center',
              if message
                messageIcon = E class: 'fa fa-envelope'
            if message
              $(messageIcon).tooltip
                html: true
                placement: 'right'
                trigger: 'manual'
                template: '<div class="tooltip" role="tooltip"><div class="tooltip-arrow"></div><div class="tooltip-inner" style="font-size: 15px"></div></div>'
                title: message.replace '\n', '<br />'
              visible = false
              unbinds.push onEvent document.body, 'mousemove', (e) ->
                element = e.target
                while element isnt document.body and element isnt td
                  element = element.parentNode
                if element is td and not visible
                  $(messageIcon).tooltip 'show'
                  visible = true
                if element isnt td and visible
                  $(messageIcon).tooltip 'hide'
                  visible = false
              unbinds.push onEvent document.body, 'mouseout', (e) ->                  
                from = e.relatedTarget || e.toElement
                if !from || from.nodeName == 'HTML'
                  if visible
                    $(messageIcon).tooltip 'hide'
                  visible = false
            return td
          unless isClosed
            do ->
              changeStatus = E 'td', cursor: 'pointer',
                E class: 'btn btn-default', cursor: 'pointer', 'تایید / رد'

              $(changeStatus).popover
                title: 'تایید / رد'
                trigger: 'manual'
                html: true
                container: 'body'
                content: do ->
                  content = E null,
                    E class: 'btn-group btn-group-xs',
                      accept = E 'button', class: "btn btn-#{if status is 'تایید شده' then 'success' else 'default'}", 'تایید شده'
                      reject = E 'button', class: "btn btn-#{if status is 'رد شده' then 'danger' else 'default'}", 'رد شده'
                      dismiss = E 'button', class: "btn btn-#{if status is 'در حال بررسی' then 'info' else 'default'}", 'در حال بررسی'
                    if status is 'تایید شده'
                      [
                        E class: 'checkbox',
                          E 'label', null,
                            do ->
                              checkbox = E 'input', type: 'checkbox', cursor: 'pointer', checked: requestForAssistant.isChiefTA
                              onEvent checkbox, 'change', ->
                                if isClosed
                                  return setStyle checkbox, checked: !checkbox.checked
                                requestForAssistant.isChiefTA = checkbox.checked
                                sendUpdate requestForAssistant
                              return checkbox
                            document.createTextNode 'دستیار اصلی است.'
                        E 'span', fontWeight: 'bold', 'وظایف:'
                        E class: 'well well-sm',
                          allChores.map ({id, persianName}) ->
                            E class: 'checkbox',
                              E 'label', null,
                                do ->
                                  checkbox = E 'input', type: 'checkbox', cursor: 'pointer', checked: chores.some (choreId) -> String(choreId) is String(id)
                                  onEvent checkbox, 'change', ->
                                    if isClosed
                                      return setStyle checkbox, checked: !checkbox.checked
                                    remove chores, id
                                    if checkbox.checked
                                      chores.push id
                                    sendUpdate requestForAssistant
                                  return checkbox
                                document.createTextNode persianName
                      ]
                  onEvent [accept, reject, dismiss], 'click', (e) ->
                    status = e.target.innerText or e.target.innerHTML
                    unless status is 'تایید شده'
                      requestForAssistant.chores = []
                      requestForAssistant.isChiefTA = false
                    extend requestForAssistant, {status}
                    update()
                    sendUpdate requestForAssistant
                    $(changeStatus).popover 'hide'
                  return content
              hidePopovers.push $(changeStatus).popover.bind $(changeStatus), 'hide'
              if requestForAssistant.id is popoveredId
                setTimeout ->
                  $(changeStatus).popover 'show'
              onEvent changeStatus, 'click', ->
                $(changeStatus).popover 'show'
                popoveredId = requestForAssistant.id
              unbinds.push onEvent document, 'click', (e) ->
                element = e.target
                while element isnt null and element isnt document.body
                  if element is changeStatus or ~(element.getAttribute?('class') or '').indexOf 'popover'
                    return
                  element = element.parentNode
                $(changeStatus).popover 'hide'
                setTimeout ->
                  if requestForAssistant.id is popoveredId
                    popoveredId = undefined
              return changeStatus
        ]

      append requestsList, table
        notStriped: true
        headerNames: ['نام'].concat(requiredCourses.map (courseId) -> "نمره درس #{getCourse(courseId).name}").concat(['معدل کل', 'مطقع', 'در کارگاه آموزش دستیاران آموزشی شرکت کرده است', 'پیام دانشجو']).concat (if isClosed then [] else ['تایید / رد'])
        sort: sort
        onResort: (s) -> sort = s
        headerSortKeys: do ->
          ['fullName']
          .concat(requiredCourses.map (courseId) ->
            id = courseId
            name: "course#{courseId}", value: ({grades}) ->
              [grade] = grades.filter ({courseId}) -> String(courseId) is String(id)
              if grade
                grade.grade
              else
                -1
          )
          .concat ['gpa', 'degree', 'isTrained', null]
          .concat (if isClosed then [] else ['status'])
        onData: (callback) -> callback -> requestForAssistants
        createRow: (requestForAssistant) ->
          {status} = requestForAssistant
          E 'tr', backgroundColor: (if status is 'تایید شده' then '#E5FFE5' else if status is 'رد شده' then '#E5E5E5'), color: (if status is 'تایید شده' then '#040' else if status is 'رد شده' then '#777'),
            getTds requestForAssistant
        updateRow: (requestForAssistant, tr) ->
          {status} = requestForAssistant
          empty tr
          setStyle tr, backgroundColor: (if status is 'تایید شده' then '#E5FFE5' else if status is 'رد شده' then '#E5E5E5'), color: (if status is 'تایید شده' then '#040' else if status is 'رد شده' then '#777'),
          append tr, getTds requestForAssistant