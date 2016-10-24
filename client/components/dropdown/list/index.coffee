component = require '../../../utils/component'
style = require './style'

module.exports = component 'dropdownList', ({dom, events, returnObject}, {getTitle, sortCompare}) ->
  {E, empty, append, setStyle} = dom
  {onMouseover} = events

  list = E style.list

  entities = items = visible = index = undefined
  highlightCurrentItem = ->
    unless items?.length
      return
    setStyle items, style.item
    setStyle items[index], style.highlightedItem

  returnObject
    set: (_entities) ->
      index = 0
      empty list
      entities = _entities.sort (a, b) ->
        sortCompare getTitle(a), getTitle(b)
      append list, items = entities.map (entity, i) ->
        item = E englishText: getTitle entity
        onMouseover item, ->
          unless visible
            return
          index = i
          highlightCurrentItem()
        item
      highlightCurrentItem()
    goUp: ->
      index--
      if index < 0
        index = 0
      highlightCurrentItem()
    goDown: ->
      index++
      if index >= entities.length
        index = entities.length - 1
      highlightCurrentItem()
    value: ->
      if entities? and index?
        entities[index]
    show: ->
      setStyle list, style.visibleList
      visible = true
    hide: ->
      setStyle list, style.list
      visible = false
      
  list