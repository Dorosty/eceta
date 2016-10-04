component = require '../../../utils/component'
{body} = require '../../../utils/dom'

module.exports = component 'offeringsMultiselect', ({dom, events, returnObject}, setSelectedRows) ->
  {E, setStyle, addClass, removeClass} = dom
  {onEvent} = events

  group = E class: 'btn-group', marginLeft: 10,
    button = E class: 'btn btn-default dropdown-toggle',
      E 'span', class: 'caret', cursor: 'pointer'
      checkbox = E 'input', type: 'checkbox', marginRight: 10, position: 'relative', top: 3
    list = E 'ul', class: 'dropdown-menu',
      l0 = E 'li', null, E 'a', cursor: 'pointer', 'انتخاب همه'
      l1 = E 'li', null, E 'a', cursor: 'pointer', 'انتخاب هیچ'

  onEvent button, 'click', checkbox, ->
    addClass group, 'open'
  onEvent E(body), 'click', [button, list], ->
    removeClass group, 'open'
  onEvent [l0, l1, l2, l3], 'click', ->
    removeClass group, 'open'
  onEvent checkbox, 'change', ->
    setSelectedRows (rows) -> if checkbox.checked() then rows else []
  onEvent l0, 'click', ->
    setSelectedRows (rows) -> rows
  onEvent l1, 'click', ->
    setSelectedRows (rows) -> []

  returnObject
    setChecked: (descriptors) ->
      setStyle checkbox, checked: descriptors.length and descriptors.every ({selected}) -> selected

  group