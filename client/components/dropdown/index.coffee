component = require '../../utils/component'
style = require './style'
list = require './list'
_functions = require './functions'
_eventHandlers = require './eventHandlers'
{extend, toPersian, compare} = require '../../utils'

module.exports = component 'dropdown', ({dom, events, returnObject}, args = {}) ->
  {E, setStyle} = dom

  {getId = ((x) -> x), getTitle = ((x) -> x), sortCompare = compare, english} = args

  variables =
    english: english
    items: []
    allItems: []
    showEmpty: false
    selectedId: null
    manuallySelected: false

  getId = do (getId) ->
    (x) ->
      if x is -1
        -1
      else
        getId x
  getTitle = do (getTitle) ->
    (x) ->
      if x is -1
        ''
      else if variables.english
        getTitle x
      else
        toPersian getTitle x
  
  components = {}
  components.dropdown = E style.dropdown,
    components.input = E 'input', style.input
    components.arrow = E 'i', style.arrow
    components.itemsList = E list, {getTitle, sortCompare}

  functions = _functions.create {variables, components, dom}
  extend functions, {getId, getTitle}
  _eventHandlers.do {components, variables, functions, dom, events}

  {reset, undirty, setSelectedId, showEmpty, update, value, setValue} = functions
  returnObject {reset, undirty, setSelectedId, showEmpty, update, value, setValue, input: components.input}

  components.dropdown