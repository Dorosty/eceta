component = require '../utils/component'

module.exports = component 'alert', ({dom, events, returnObject}) ->
  {E, addClass, removeClass, setStyle} = dom
  {onEvent} = events

  alert = E class: 'alert fade', position: 'absolute', top: 100, left: '20%', right: '20%',
    close = E 'button', class: 'close', zIndex: 10, '×'
    text = E 'h4'

  onEvent close, 'click', ->
    removeClass alert, 'in'

  returnObject
    show: (_text, isOk) ->
      removeClass alert, ['success', 'danger'].map (x) -> "alert-#{x}"
      addClass alert, ['in', "alert-#{if isOk then 'success' else 'danger'}"]
      setStyle text, text: _text
    hide: ->
      removeClass alert, 'in'

  alert