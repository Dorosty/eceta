ajax = require './ajax'
stateChangingServices = require './stateChangingServices'
ex = require './ex'
{states} = require './names'
{eraseCookie} = require '../cookies'
state = require '../state'

handle = (isGet) -> (serviceName, params) ->
  stateChangingServices[serviceName]?.running = true
  startedAt = +new Date()
  ajax isGet, serviceName, params
  .then (response) ->
    stateChangingServices[serviceName]?.running = false
    stateChangingServices[serviceName]?.endedAt = +new Date()
    states.forEach (name) ->
      dontSetState = Object.keys(stateChangingServices).some (_serviceName) ->
        service = stateChangingServices[_serviceName]
        if service.stateName is name or _serviceName is 'logout'
          if _serviceName is serviceName
            false
          else if service.running
            true
          else unless service.endedAt
            false
          else
            service.endedAt >= startedAt
        else
          false
      if dontSetState
        state.person.on once: true, allowNull: true, (person) ->
          unless person
            eraseCookie 'id'
      else
        if response[name]
          responseValue = response[name]
          setTimeout ->
            state[name].set responseValue
        if name is 'person' and response.loggedOut
          setTimeout ->
            ex.logout true
    delete response.person
    delete response.loggedOut
    if response.value?
      response = response.value
    response

exports.get = handle true
exports.post = handle false