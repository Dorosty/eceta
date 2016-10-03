component = require '../../utils/component'
Q = require '../../q'
_functions = require './functions'

module.exports = component 'modal', ({dom, events, returnObject}) ->
  {E, disable} = dom
  {onEvent} = events

  variables =
    enabled: false
    autoHide: false

  components =
    modal: undefined
    title: undefined
    contents: undefined
    submit: undefined
    close: undefined
  components.modal = E class: 'modal fade',
  E 'div', class: 'modal-dialog',
    E 'div', class: 'modal-content',
      E 'div', class: 'modal-header',
        E 'button', class: 'close'
        components.title = E 'h4', class: 'modal-title'
      components.contents = E 'div', class: 'modal-body'
      E 'div', class: 'modal-footer',
        components.submit = E 'button', class: 'btn btn-primary'
        components.close = E 'button', class: 'btn btn-default'

  functions = _functions.create {variables, components, dom}

  functions.newSubmit = ->
    return unless variables.enabled
    if variables.autoHide
      disable components.submit
      Q functions.submit()
      .fin -> functions.hide()
      .done()
    else
      functions.submit()

  onEvent components.close, 'click', functions.hide
  onEvent components.submit, 'click', functions.newSubmit

  returnObject
    setEnabled: functions.setEnabled
    display: functions.display
    submit: functions.newSubmit
    hide: functions.hide

  components.modal