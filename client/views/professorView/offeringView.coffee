
Q = require './q'
{extend, E, setStyle, show, hide, empty, append, bindEvent, toPersian, remove, addClass, removeClass, dropdown, table} = require './utils'
state = require './state'
credit = require './views/credit'
modal = require './modal'

tagStyle =
  borderRadius: 3
  display: 'inline-block'
  fontWeight: 'bold'
  marginLeft: 4
  padding: '2px 6px'
  height: 25
  lineHeight: 21
  color: '#31708f'
  backgroundColor: '#d9edf7'
  border: '1px solid #bce8f1'

addTagStyle = extend {}, tagStyle,
  color: '#3c763d'
  backgroundColor: '#dff0d8'
  borderColor: '#d6e9c6'
  cursor: 'pointer'

tagAdornerStyle =
  fontWeight: 'bold'
  cursor: 'pointer'
  cursor: 'pointer'

tagXStyle = extend {}, tagAdornerStyle,
  color: '#d43f3a'

isTableView = false

view = E class: 'col-md-9', marginTop: 40,
  E marginBottom: 100,
    title = E 'h1', float: 'right'
    closeOffering = E 'button', class: 'btn btn-success', float: 'left', marginTop: 20, 'نهایی کردن انتخاب دستیاران...'
  requiredCoursesSection = E null,
    E 'h4', fontWeight: 'bold', display: 'inline-block', 'لیست دروس مرتبط'
    E 'span', null, ' (درس‌هایی که دانشجو موظف است نمره خود را در آنها اعلام کند)'
    E margin: '10px 0 60px', position: 'relative',
      requiredCoursesList = E display: 'inline-block'
      addTag = E addTagStyle,
        E 'span', tagAdornerStyle, '+ '
        E 'span', cursor: 'pointer', 'افزودن درس'
      coursesCover = E position: 'absolute', top: 0, left: 0, right: 0, bottom: 0, background: 'white', transition: '0.5s'
  E null,
    E float: 'left',
      requestsToggleView = E class: 'btn-group',
        tableViewButton = E 'button', class: 'btn btn-default',
          E class: 'fa fa-table', cursor: 'pointer'
        listViewButton = E 'button', class: 'btn btn-primary',
          E class: 'fa fa-bars', cursor: 'pointer'
    E 'h4', fontWeight: 'bold', marginBottom: 35, 'لیست درخواست‌های دانشجویان'
    requestsList = E()

cover = ->
  setStyle coursesCover, opacity: 0.5, visibility: 'visible'
do uncover = ->
  setStyle coursesCover, opacity: 0, visibility: 'hidden'

bindEvent listViewButton, 'click', ->
  isTableView = false
  removeClass listViewButton, 'btn-default'
  removeClass tableViewButton, 'btn-primary'
  addClass listViewButton, 'btn-primary'
  addClass tableViewButton, 'btn-default'
  update()

bindEvent tableViewButton, 'click', ->
  isTableView = true
  removeClass listViewButton, 'btn-primary'
  removeClass tableViewButton, 'btn-default'
  addClass listViewButton, 'btn-default'
  addClass tableViewButton, 'btn-primary'
  update()

addCourseDropdown = dropdown ((course) -> String course.id), (course) -> course.name

isEditing = false
courses = allChores = offering = unbindAddTag = unbindClose = popoveredId = sort = undefined 
lastRequest = Q()
unbinds = []
hidePopovers = []

getCourse = (courseId) -> (courses.filter ({id}) -> String(id) is String(courseId))[0]

addTagSubmit = undefined
addTagDialog = credit(
  getTitle: -> 'افزودن درس'
  getSubmitText: -> 'افزودن'
  isEnabled: -> addCourseDropdown.element.value
  fields: [
    {name: 'نام درس', element: addCourseDropdown.element, dropdown: addCourseDropdown, dropdownState: 'courses'}
  ]
  create: -> addTagSubmit()
)(false)

exports.update = update = (_offering) ->
  unbinds.forEach (unbind) -> unbind()
  unbinds = []
  hidePopovers.forEach (hide) -> hide()
  hidePopovers = []

  if _offering
    offering = _offering

  return unless offering

  {courseId, requiredCourses, requestForAssistants, isClosed} = offering

  service = require './service'

  addTagSubmit = ->
    service.addRequiredCourse
      courseId: addCourseDropdown.element.value
      offeringId: offering.id
    .fin modal.hide
  unbindAddTag?()
  unbindAddTag = bindEvent addTag, 'click', addTagDialog

  {name: courseName} = getCourse courseId

  unbindClose?()
  unbindClose = bindEvent closeOffering, 'click', ->
    accepted = requestForAssistants.filter(({status}) -> status is 'تایید شده').map ({fullName}) -> fullName
    modal.display
      contents: [
        E 'h2', color: 'red', marginBottom: 30, 'آیا از نهایی کردن فهرست دستیاران اطمینان دارید؟'
        E fontWeight: 'bold', fontSize: 15,
          E marginBottom: 10, if accepted.length then "دستیاران انتخاب‌شده برای درس «#{courseName}»:" else 'شما دانشجویی را به عونان دستیار تایید نکرده‌اید.'
          if accepted.length
            [
              E 'ul', null, accepted.map (fullName) ->
                E 'li', null, fullName
              E marginTop: 20, 'در صورت نهایی کردن، رایانامه‌ای به این دانشجویان مبنی بر پذیرش آنها ارسال خواهد شد.'
            ]
      ]
      submitText: 'نهایی کردن'
      submitType: 'danger'
      closeText: 'انصراف'
      enabled: true
      onSubmit: ->
        modal.setEnabled false
        service.closeOffering id: offering.id
        .fin modal.hide

  setStyle title, text: toPersian "درس #{courseName}"
  if requestForAssistants.length
    show requestsToggleView
  else
    hide requestsToggleView

  if isClosed
    hide [addTag, closeOffering, requiredCoursesSection]
  else
    show [addTag, closeOffering, requiredCoursesSection]

    empty requiredCoursesList
    append requiredCoursesList, requiredCourses.map (courseId) ->
      {name} = getCourse courseId
      tag = E tagStyle,
        x = E 'span', tagXStyle, '× '
        E 'span', null, toPersian name

      bindEvent x, 'click', ->
        cover()
        service.removeRequiredCourse {courseId, offeringId: offering.id}
        .fin uncover

      return tag

  empty requestsList

  sendUpdate = (requestForAssistant) ->
    isEditing = true
    lastRequest = lastRequest.then ->
      isEditing = true
      service.changeRequestForAssistant
        id: requestForAssistant.id
        isChiefTA: requestForAssistant.isChiefTA
        choreIds: requestForAssistant.chores
        status: requestForAssistant.status
    .fin -> isEditing = false

  if requestForAssistants.length
    if isTableView

      getTds = (requestForAssistant) ->
        {gpa, isTrained, message, fullName, email, degree, grades, chores, status} = requestForAssistant
        [
          E 'td', null, fullName
          requiredCourses.map (courseId) ->
            id = courseId
            [grade] = grades.filter ({courseId}) -> String(courseId) is String(id)
            E 'td', null, if grade? then toPersian grade.grade else '(وارد نشده)'
          E 'td', null, toPersian gpa
          E 'td', null, degree
          do ->
            td = E 'td', textAlign: 'center',
              checkbox = E 'input', type: 'checkbox', checked: isTrained
            bindEvent checkbox, 'change', ->
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
              unbinds.push bindEvent document.body, 'mousemove', (e) ->
                element = e.target
                while element isnt document.body and element isnt td
                  element = element.parentNode
                if element is td and not visible
                  $(messageIcon).tooltip 'show'
                  visible = true
                if element isnt td and visible
                  $(messageIcon).tooltip 'hide'
                  visible = false
              unbinds.push bindEvent document.body, 'mouseout', (e) ->                  
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
                              bindEvent checkbox, 'change', ->
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
                                  bindEvent checkbox, 'change', ->
                                    if isClosed
                                      return setStyle checkbox, checked: !checkbox.checked
                                    remove chores, id
                                    if checkbox.checked
                                      chores.push id
                                    sendUpdate requestForAssistant
                                  return checkbox
                                document.createTextNode persianName
                      ]
                  bindEvent [accept, reject, dismiss], 'click', (e) ->
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
              bindEvent changeStatus, 'click', ->
                $(changeStatus).popover 'show'
                popoveredId = requestForAssistant.id
              unbinds.push bindEvent document, 'click', (e) ->
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
    else
      append requestsList, requestForAssistants.map (requestForAssistant) ->

        {gpa, isTrained, message, fullName, email, degree, grades, chores, status} = requestForAssistant
        card = E class: "panel panel-#{if status is 'تایید شده' then 'success' else if status is 'رد شده' then 'danger' else 'info'}",
          E class: 'panel-heading',
            E float: 'left',
              E class: 'btn-group btn-group-xs', do ->
                accept = E 'button', class: "btn btn-#{if status is 'تایید شده' then 'success' else 'default'}", 'تایید شده'
                reject = E 'button', class: "btn btn-#{if status is 'رد شده' then 'danger' else 'default'}", 'رد شده'
                dismiss = E 'button', class: "btn btn-#{if status is 'در حال بررسی' then 'info' else 'default'}", 'در حال بررسی'
                bindEvent [accept, reject, dismiss], 'click', (e) ->
                  status = e.target.innerText or e.target.innerHTML
                  unless status is 'تایید شده'
                    requestForAssistant.chores = []
                    requestForAssistant.isChiefTA = false
                  extend requestForAssistant, {status}
                  update()
                  sendUpdate requestForAssistant
                unless isClosed
                  [accept, reject, dismiss]
            unless isClosed
              E float: 'left', marginLeft: 10, 'تغییر وضعیت درخواست:'
            E 'h3', class: 'panel-title', fontWeight: 'bold',
              document.createTextNode "#{fullName} ("
              E 'a', cursor: 'pointer', fontWeight: 'lighter', fontSize: 13, target: '_blank', href: "mailto:#{email}", email
              document.createTextNode ')'
          cardBody = E class: 'panel-body',
            E class: 'col-md-5',
              E 'ul', null,
                requiredCourses.map (courseId) ->
                  {id, name} = getCourse courseId
                  [grade] = grades.filter ({courseId}) -> String(courseId) is String(id)
                  E 'li', null, "نمره درس #{toPersian name}: #{if grade? then toPersian grade.grade else '(وارد نشده)'}"
                E 'li', null,
                  E 'span', fontWeight: 'bold', "معدل کل: #{toPersian gpa}"
                E 'li', null, "مقطع: #{degree}"
                E 'li', null,
                  document.createTextNode 'در کارگاه آموزش دستیاران آموزشی شرکت '
                  E 'span', fontWeight: 'bold', color: (if isTrained then 'green' else 'red'), if isTrained then 'کرده است.' else 'نکرده است.'
            cardMessageBorder = E class: 'col-md-4', borderLeft: '1px dashed #AAA', borderRight: '1px dashed #AAA',
              if message 
                messageSpan = E 'span'
                messageSpan.innerHTML = message.replace '\n', '<br />'
                [
                  E fontWeight: 'bold', marginBottom: 10, 'پیام دانشجو: '
                  messageSpan
                ]
            E class: 'col-md-3',
              if status is 'تایید شده' then [
                E class: 'checkbox',
                  E 'label', null,
                    do ->
                      checkbox = E 'input', type: 'checkbox', cursor: 'pointer', checked: requestForAssistant.isChiefTA
                      bindEvent checkbox, 'change', ->
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
                          bindEvent checkbox, 'change', ->
                            if isClosed
                              return setStyle checkbox, checked: !checkbox.checked
                            remove chores, id
                            if checkbox.checked
                              chores.push id
                            sendUpdate requestForAssistant
                          return checkbox
                        document.createTextNode persianName
              ]

        if message
          setTimeout ->
            setStyle cardMessageBorder, height: cardBody.offsetHeight - 30

        return card
  else
    append requestsList, E null, 'هنوز دانشجویی درخواست دستیاری در این درس نکرده است.'


offState = undefined
exports.createElement = ->
  offState = state.all ['courses', 'chores'], ([_courses, _chores,]) ->
    [courses, allChores] = [_courses, _chores]
    update()
  return view

exports.isEditing = -> isEditing
exports.off = -> offState()
