component = require '../utils/component'
style = require './style'
email = require './email'
bugReport = require './bugReport'

module.exports = component 'navbar', ({dom, events, service, state}) ->
  {E, append, setStyle, show, hide} = dom
  {onEvent} = events
  
  navbar = E style.navbar,
    E style.wrapper,
      E style.title, 'سامانه مدیریت دستیاران آموزشی'
      E style.betaDisclaimer, '- نسخه آزمایشی'
      E bugReport
      personBox = E style.personBox

  append personBox, [
    emailBox = E email, container: personBox.fn.element
    personName = E style.personName
    logout = E 'a', style.logout, 'خروج'
  ]

  onEvent logout, 'click', ->
    emailBox.hidePopover()
    service.logout()

  state.person.on allowNull: true, (person) ->
    if person
      setStyle personName, text: person.fullName
      show personBox
    else
      hide personBox

  navbar