style = require './style'
{collection, compare} = require '../../utils'

exports.create = ({headers, properties, handlers, variables, components, dom, events}) ->
  {E, destroy, append, setStyle, show, hide, addClass, removeClass} = dom
  {onEvent} = events

  functions =
    cover: ->
      setStyle components.cover, style.cover

    uncover: ->
      setStyle components.cover, style.hiddenCover

    update: ->
      if variables.descriptors
        hide components.noData
        show components.yesData
        if variables.sort
          variables.descriptors = variables.descriptors.sort ({entity: a}, {entity: b}) ->
            header = variables.sort.header
            if variables.sort.direction is 'up'
              [first, second] = [a, b]
            else
              [first, second] = [b, a]
            if header.getValue
              firstValue = header.getValue first
              secondValue = header.getValue second
            else
              firstValue = first[header.key]
              secondValue = second[header.key]
            result = compare firstValue, secondValue
            if result is 0 and variables.entityId
              compare first[variables.entityId], second[variables.entityId]
            else
              result
      descriptors = variables.descriptors or []
      variables.selectionMode = descriptors.some ({selected}) -> selected
      functions.handleRows descriptors
      handlers.update? descriptors

    setData: (entities) ->
      unless variables.descriptors
        variables.descriptors = entities.map (entity) -> {entity}
      else
        variables.descriptors = entities.map (entity) ->
          returnValue = undefined
          shouldReturn = variables.descriptors.some (x) ->
            if functions.isEqual entity, x.entity
              returnValue = x
              true
          if shouldReturn
            returnValue.entity = entity
            returnValue
          else
            {entity}
      functions.update()

    setSelectedRows: (callback) ->
      variables.descriptors.forEach (descriptor) -> descriptor.selected = false
      callback(variables.descriptors).forEach (descriptor) -> descriptor.selected = true
      functions.update()

    setSort: (header) ->
      headers.forEach ({arrow}) -> hide arrow
      show header.arrow
      sort = variables.sort
      if sort?.header is header and sort.direction is 'up'
        setStyle header.arrow, class: 'fa fa-caret-down'
        sort.direction = 'down'
      else
        setStyle header.arrow, class: 'fa fa-caret-up'
        variables.sort = header: header, direction: 'up'
      functions.update()

    styleTd: (header, {entity}, td, row) ->
      if header.key
        setStyle td, text: entity[header.key]
      else if header.englishKey
        setStyle td, englishText: entity[header.englishKey]
      else if header.getValue
        setStyle td, text: header.getValue entity
      if header.styleTd
        header.styleTd entity, td, row.offs, row
      td

    setupRow: (row, descriptor) ->
      row.off = ->
        row.offs.forEach (x) -> x()
        row.offs = []
      unless functions.styleRow
        setStyle row.tr, class: if descriptor.selected
          'info'
        else
          ''
      else
        functions.styleRow descriptor.entity, row.tr
      if handlers.select and not descriptor.unselectable
        row.offs.push onEvent row.tr, 'mousemove', ->
          if not variables.selectionMode or descriptor.selected
            addClass row.tr, 'info'
          else
            removeClass row.tr, 'info'
        row.offs.push onEvent row.tr, 'mouseout', ->
          if variables.selectionMode and descriptor.selected
            addClass row.tr, 'info'
          else
            removeClass row.tr, 'info'
      if properties.multiSelect
        setStyle row.checkbox, checked: !!descriptor.selected
        row.offs.push onEvent row.checkbox, 'change', ->
          descriptor.selected = row.checkbox.checked()
          functions.update()
      if handlers.select and not descriptor.unselectable
        row.tds.forEach (td) ->
          setStyle td, cursor: 'pointer'
        notClickableTds = row.tds.filter (_, i) -> headers[i].notClickable
        if properties.multiSelect
          notClickableTds.push row.checkboxTd
        row.offs.push onEvent row.tr, 'click', notClickableTds, ->
          handlers.select descriptor.entity
      row

    addRow: (descriptor) ->
      row = offs: []
      append components.body, row.tr = E 'tr', null,
        if properties.multiSelect
          row.checkboxTd = E 'td', null,
            row.checkbox = E 'input', type: 'checkbox'
        row.tds = headers.map (header) ->
          functions.styleTd header, descriptor, E('td'), row
      functions.setupRow row, descriptor

    changeRow: (descriptor, row) ->
      row.off()
      row.tds.forEach (td, index) ->
        functions.styleTd headers[index], descriptor, td, row
      functions.setupRow row, descriptor

    removeRow: (row) ->
      row.off()
      destroy row.tr

  functions.handleRows = collection functions.addRow, functions.removeRow, functions.changeRow
  functions