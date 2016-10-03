{textIsInSearch} = require '../../utils'

exports.create = ({components, variables, dom}) ->
  {input, itemsList} = components
  {setStyle} = dom

  functions =
    setInputValue: (value) ->
      if variables.english
        setStyle input, englishValue: value
      else
        setStyle input, value: value

    getFilteredItems: ->
      variables.allItems.filter (item) -> textIsInSearch functions.getTitle(item), input.value()

    updateDropdown: ->
      unless document.activeElement is input.fn.element
        if variables.selectedId?
          selectedItem = variables.allItems.filter((i) -> String(functions.getId(i)) is variables.selectedId)[0]
          if selectedItem?
            functions.setInputValue functions.getTitle selectedItem
          else
            functions.setInputValue ''
        else
          filteredItems = functions.getFilteredItems()
          if filteredItems.length
            functions.setInputValue functions.getTitle filteredItems[0]
          else
            functions.setInputValue ''
        itemsList.set functions.getFilteredItems()

    
    showEmpty: (showEmpty) ->
      variables.showEmpty = showEmpty
      functions.update variables.items
    update: (items) ->
      variables.items = items
      if variables.showEmpty
        variables.allItems = [-1].concat items
      else
        variables.allItems = items
      functions.updateDropdown()
    reset: ->
      variables.selectedId = null
      variables.manuallySelected = false
      functions.setInputValue ''
      functions.updateDropdown()
    setSelectedId: (id) ->
      unless variables.manuallySelected
        variables.selectedId = String id
        functions.updateDropdown()
    undirty: ->
      variables.manuallySelected = false
    value: ->
      itemsList.value() ? -1