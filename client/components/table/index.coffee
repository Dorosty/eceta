component = require '../../utils/component'
style = require './style'
_functions = require './functions'
{extend} = require '../../utils'

module.exports = component 'table', ({dom, events, returnObject}, {headers, entityId, isEqual, sort, styleRow, properties = {}, handlers = {}}) ->
  {E, text, hide} = dom
  {onEvent} = events

  hasSearchBoxes = headers.some (header) -> header.searchBox
  entityId ?= 'id'
  isEqual ?= (a, b) ->
    a[entityId] is b[entityId]

  variables =
    entityId: entityId
    headers: []
    descriptors: null
    sort: sort or {
      header: headers[0]
      direction: 'up'
    }

  components = {}

  functions = _functions.create {headers, properties, handlers, variables, components, dom, events}
  extend functions, {isEqual, styleRow}

  table = E position: 'relative',
    components.noData = E null, 'در حال بارگذاری...'
    hide components.yesData = E null,
      E 'table', class: 'table table-bordered ' + (if properties.notStriped then '' else 'table-striped'),
        E 'thead', null,
          E 'tr', null,
            if properties.multiSelect
              E 'th', width: 20
            headers.map (header) ->
              th = E 'th', extend({cursor: if header.key or header.getValue then 'pointer' else 'default'}, style.th),
                header.arrow = E style.arrow
                if hasSearchBoxes
                  [
                    E style.headerWithSearchBox, header.name
                    header.searchBox
                  ]
                else
                  text header.name
              if header.key or header.getValue
                onEvent th, 'click', header.searchBox, ->
                  functions.setSort header
              th
        components.body = E 'tbody', null
    components.cover = E style.cover

  functions.uncover()

  returnObject
    cover: functions.cover
    uncover: functions.uncover
    setData: functions.setData
    setSelectedRows: functions.setSelectedRows

  table
