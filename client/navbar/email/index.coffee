component = require '../../utils/component'
style = require './style'
{emailIsValid} = require '../../utils/logic'
{document, body} = require '../../utils/dom'

module.exports = component 'navbarEmail', ({dom, events, state, service, returnObject}, {container}) ->
  {E, setStyle, show, hid, enable, disable} = dom
  {onEvent, onEnter} = events

  currentEmail = undefined
  enabled = false

  icon = E style.icon
  content = E style.content,
    input =  E 'input', style.input
    submit = E 'button', style.submit, 'تغییر ایمیل'

  setEnabled = ->
    enabled = input.value() and emailIsValid input.value()
    if enabled
      enable submit
    else
      disable submit

  $(icon.fn.element).popover
    title: 'مشاهده/ویرایش ایمیل'
    trigger: 'manual'
    html: true
    container: container
    content: ->
      setStyle input, value: currentEmail
      setEnabled()
      content.fn.element

  showPopover = ->
    $(icon.fn.element).popover 'show'
  hidePopover = ->
    $(icon.fn.element).popover 'hide'

  onEvent input, 'input', setEnabled

  onEvent icon, 'click', showPopover
  onEvent E(document), 'click', (e) ->
    unless currentEmail
      return
    element = e.target
    while element isnt null and element isnt E(body).fn.element
      if element is icon.fn.element or ~(element.getAttribute?('class') or '').indexOf 'popover'
        return
      element = element.parentNode
    hidePopover()

  doSubmit = ->
    unless enabled
      return
    disable submit
    service.changeEmail email: input.value()
    .then ->
      hidePopover()
      enable submit

  onEvent submit, 'click', doSubmit
  onEnter input, doSubmit

  state.person.on allowNull: true, (person) ->
    if person
      currentEmail = person.email
      setEnabled()
      unless currentEmail
        setTimeout showPopover

  returnObject {hidePopover}
    
  icon
