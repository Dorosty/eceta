component = require '../../utils/component'
dropdown = require '.'
{extend} = require '../../utils'

module.exports = component 'stateSyncedDropdown', ({dom, state, returnObject}, {getId, getTitle, stateName, selectedIdStateName, english, sortCompare}) ->
  {E} = dom

  d = E dropdown, {getId, getTitle, english, sortCompare}

  state[stateName].on (data) ->
    d.update data
  if selectedIdStateName
    state[selectedIdStateName].on (id) ->
      d.setSelectedId id
  
  {reset, undirty, showEmpty, value} = d
  ret = {reset, undirty, showEmpty, value}
  unless selectedIdStateName
    ret.setSelectedId = d.setSelectedId
  if d.input
    ret.input = d.input
  ret.revalue = ->
    d.undirty()
    state[selectedIdStateName].on once: true, (id) ->
      d.setSelectedId id
  returnObject ret

  d