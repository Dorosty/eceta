Q = require '../../q'
state = require '../state'
stateChangingServices = require './stateChangingServices'
{gets, posts, cruds} = require './names'
{get, post} = require './getPost'
{eraseCookie} = require '../cookies'
{uppercaseFirst} = require '..'

exports.logout = (automatic) ->
  unless automatic is true
    stateChangingServices.logout.running = true
  [
    'person'
    'gpa'
    'grades'
    'isTrained'
  ].forEach (x) -> state[x].set null
  
  eraseCookie 'id'
  unless automatic is true
    eraseCookie 'data'

  state.cas.on once: true, allowNull: true, (cas) ->
    unless automatic is true
      stateChangingServices.logout.running = false
      stateChangingServices.logout.endedAt = +new Date()
    if cas
      while document.body.children.length
        document.body.removeChild document.body.children[0]
      location.href = 'https://auth.ut.ac.ir:8443/cas/logout'

  Q()
      
exports.casLogin = (x) ->
  post 'casLogin', x
  .then ->
    state.cas.set true

exports.setStaticData = (x) ->
  post 'setStaticData', x
  .then ->
    x.forEach (x) ->
      if x.key is 'currentTerm'
        state.currentTerm.set x.value

gets.forEach (x) ->
  exports[x] = (params) ->
    get x, params

posts.forEach (x) ->
  exports[x] = (params) ->
    post x, params

cruds.forEach ({name, persianName}) ->
  posts.push serviceName = "update#{uppercaseFirst(name)}"  
  exports[serviceName] = (entity) ->
    post serviceName, entity
    .then ->
      state["#{name}s"].on once: true, (entities) ->
        entities = entities.filter ({id}) -> id isnt entity.id
        entities.push entity
        state["#{name}s"].set entities

cruds.forEach ({name, persianName}) ->
  posts.push serviceName = "create#{uppercaseFirst(name)}"
  exports[serviceName] = (entity) ->
    post serviceName, entity
    .then (id) ->
      state["#{name}s"].on once: true, (entities) ->
        extend entity, {id}
        entities.push entity
        state["#{name}s"].set entities

cruds.forEach ({name, persianName}) ->
  posts.push serviceName = "delete#{uppercaseFirst(name)}s"
  exports[serviceName] = (ids) ->
    post serviceName, {ids}
    .then ->
      state["#{name}s"].on once: true, (entities) ->
        entities = entities.filter ({id}) -> not (id in ids)
        state["#{name}s"].set entities