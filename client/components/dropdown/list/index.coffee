component = require '../../../utils/component'
style = require './style'
{compare} = require '../../../utils'

module.exports = component 'dropdownList', ({dom, events, returnObject}, getTitle) ->
  {E, empty, append, setStyle} = dom
  {onMouseover} = events

  list = E style.list

  entities = items = index = undefined
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
        compare getTitle(a), getTitle(b)
      append list, items = entities.map (entity, i) ->
        item = E englishText: getTitle entity
        onMouseover item, ->
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
    hide: ->
      setStyle list, style.list

  list