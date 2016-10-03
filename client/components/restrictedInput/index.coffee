component = require '../../utils/component'
{toEnglish} = require '../../utils'

module.exports = component 'restrictedInput', ({dom, events, returnObject}, regex) ->  
  {E, setStyle} = dom
  {onEvent} = events

  input = E 'input'

  prevValue = ''

  onEvent input, 'input', ->
    value = toEnglish input.value()
    if regex.test value
      prevValue = value
    else
      value = prevValue
    setStyle input, {value}

  returnObject
    value: -> input.value()
  
  input