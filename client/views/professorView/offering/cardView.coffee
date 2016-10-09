component = require '../../../utils/component'
{extend} = require '../../../utils'

module.exports = component 'professorOfferingsCardView', ({dom, events}, {requestForAssistants, changeRequestForAssistant}) ->
  {E, setStyle} = dom
  {onEvent} = events

  requestForAssistants.map (requestForAssistant) ->
    card = E class: "panel panel-#{if status is 'تایید شده' then 'success' else if status is 'رد شده' then 'danger' else 'info'}",
      E class: 'panel-heading',
        E float: 'left',
          E class: 'btn-group btn-group-xs', do ->
            # reject = E 'button', class: "btn btn-#{if status is 'رد شده' then 'danger' else 'default'}", 'رد شده'
            # dismiss = E 'button', class: "btn btn-#{if status is 'در حال بررسی' then 'info' else 'default'}", 'در حال بررسی'
            unless requestForAssistant.isClosed
              ['تایید شده', 'رد شده', 'در حال بررسی'].map (x) ->
                button = E 'button', class: "btn btn-#{if status is x then 'success' else 'default'}", x
              onEvent [accept, reject, dismiss], 'click', (e) ->
                status = e.target.innerText or e.target.innerHTML
                unless status is 'تایید شده'
                  requestForAssistant.chores = []
                  requestForAssistant.isChiefTA = false
                extend requestForAssistant, {status}
                changeRequestForAssistant requestForAssistant
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
              E 'li', null, "نمره درس #{name}: #{if grade? then grade.grade else '(وارد نشده)'}"
            E 'li', null,
              E 'span', fontWeight: 'bold', "معدل کل: #{gpa}"
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
                  onEvent checkbox, 'change', ->
                    if isClosed
                      return setStyle checkbox, checked: !checkbox.checked
                    requestForAssistant.isChiefTA = checkbox.checked
                    changeRequestForAssistant requestForAssistant
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
                        changeRequestForAssistant requestForAssistant
                      return checkbox
                    document.createTextNode persianName
          ]

    if message
      setTimeout ->
        setStyle cardMessageBorder, height: cardBody.offsetHeight - 30

    card