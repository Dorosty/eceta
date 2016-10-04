component = require '../../utils/component'
restrictedInput = require '.'

module.exports = component 'numberInput', ({dom, returnObject}, isInteger) ->
  {E} = dom

  input = E restrictedInput, if isInteger then /^[0-9]*$/ else /^([0-9]*|[0-9]*\.[0-9]+)$/

  returnObject
    value: -> input.value()
  
  input