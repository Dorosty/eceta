_state = require './state'
_service = require './service'
_dom = require './dom'
_events = require './events'
log = require('./log').component
{extend} = require '.'

module.exports = (componentName, create) -> (args...) ->
  component = {}
  component.fn =
    name: componentName
    off: ->
  
  log.create 0, component

  dom = _dom.instance component
  events = _events.instance component
  state = _state.instance component
  service = _service.instance component
  returnObject = (returnObject) ->
    extend component, returnObject
  others =
    loading: (stateNames, yesData, noData) ->
      unless Array.isArray stateNames
        stateNames = [stateNames]
      dom.hide yesData
      state.all stateNames, ->
        dom.hide noData
        dom.show yesData

  c = create {dom, events, state, service, returnObject, others}, args...

  if c?.fn?.element
    component.fn.element = c.fn.element
  if c?.fn?.pInputListeners
    component.fn.pInputListeners = c.fn.pInputListeners

  log.create 1, component

  component