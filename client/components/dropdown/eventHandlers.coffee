{toPersian} = require '../../utils'

exports.do = ({components, variables, functions, dom, events}) ->
  {input, arrow, itemsList} = components
  {setStyle} = dom
  {onEvent, onEnter} = events

  onEvent arrow, 'click', ->
    input.focus()

  onEvent input, 'focus', ->
    input.select()

  onEvent input, 'focus', ->
    variables.manuallySelected = true
    itemsList.set variables.allItems
    itemsList.show()

  prevInputValue = ''
  onEvent input, 'input', ->
    variables.manuallySelected = true
    unless variables.english
      setStyle input, value: input.value()
    if functions.getFilteredItems().length
      prevInputValue = input.value()
    else
      setStyle input, englishValue: prevInputValue
    itemsList.set functions.getFilteredItems()
    itemsList.show()

  onEvent input, 'blur', ->
    if itemsList.value()?
      variables.selectedId = String functions.getId itemsList.value()
    functions.updateDropdown()
    itemsList.hide()

  onEvent input, 'keydown', (e) ->
    code = e.keyCode or e.which
    switch code
      when 40
        itemsList.goDown()
      when 38
        itemsList.goUp()

  onEnter input, ->
    input.blur()