names = require './names'
log = require('../log').state

createPubSub = (name) ->
  data = dataNotNull = undefined
  subscribers = []
  on: (options, callback) ->

    firstDataSent = false
    unless options.omitFirst
      if not options.allowNull
        if dataNotNull isnt undefined
          callback dataNotNull
          firstDataSent = true
      else
        callback data
        firstDataSent = true

    if options.once and not options.omitFirst and firstDataSent
      return ->

    subscribers.push wrappedCallback = (data) ->
      if not options.allowNull and not data?
        return

      callback data

      if options.once
        unsubscribe()
        
    unsubscribe = ->
      index = subscribers.indexOf wrappedCallback
      if ~index
        subscribers.splice index, 1
        
  set: (_data) ->

    if JSON.stringify(data) is JSON.stringify(_data)
      return

    data = _data
    if data?
      dataNotNull = data

    subscribers.forEach (callback) -> callback data

pubSubs = names.map (name) ->
  name: name
  pubSub: exports[name] = createPubSub name

exports.all = ->
  if arguments.length is 2
    [keys, callback] = arguments
    options = {}
  else
    [keys, options, callback] = arguments

  resolved = {}
  values = {}
  unsubscribes = keys.map (key) ->
    exports[key].on options, (value) ->
      resolved[key] = true
      values[key] = value
      if (keys.every (keys) -> resolved[keys])
        callback keys.map (key) -> values[key]

  unsubscribe = ->
    unsubscribes.forEach (unsubscribe) -> unsubscribe()

  unsubscribe


exports.instance = (thisComponent) ->

  exports = {}

  exports.createPubSub = (name) ->
    l = log.pubsub thisComponent, name
    pubsub = createPubSub name
    on: ->
      if arguments.length is 1
        [callback] = arguments
        options = {}
      else
        [options, callback] = arguments

      ll = l.on options, callback

      ll 0
      unsubscribe = pubSub.on options, (data) ->
        ll 1, data
        callback data
        ll 1, data
      ll 0
      unsubscribe = do (unsubscribe) -> ->
        ll 2
        unsubscribe()
        ll 2
      prevOff = thisComponent.fn.off
      thisComponent.fn.off = ->
        prevOff()
        unsubscribe()
      unsubscribe

    set: ->
      ll = l.set data
      ll()
      pubSub.set data
      ll()

  pubSubs.forEach ({name, pubSub}) ->

    l = log.pubsub thisComponent, name
    
    instancePubSub = {}

    instancePubSub.on = ->

      if arguments.length is 1
        [callback] = arguments
        options = {}
      else
        [options, callback] = arguments

      ll = l.on options, callback

      ll 0
      unsubscribe = pubSub.on options, (data) ->
        ll 1, data
        callback data
        ll 1, data
      ll 0
      unsubscribe = do (unsubscribe) -> ->
        ll 2
        unsubscribe()
        ll 2
      prevOff = thisComponent.fn.off
      thisComponent.fn.off = ->
        prevOff()
        unsubscribe()
      unsubscribe

    instancePubSub.set = (data) ->
      ll = l.set data
      ll()
      pubSub.set data
      ll()

    exports[name] = instancePubSub

  exports.all = ->

    if arguments.length is 2
      [keys, callback] = arguments
      options = {}
    else
      [keys, options, callback] = arguments

    l = log.all thisComponent, options, keys, callback

    resolved = {}
    values = {}
    l 0
    unsubscribes = keys.map (key) ->
      exports[key].on options, (value) ->
        resolved[key] = true
        values[key] = value
        if (keys.every (keys) -> resolved[keys])
          l 1
          callback keys.map (key) -> values[key]
          l 1
    l 0

    unsubscribe = ->
      l 2
      unsubscribes.forEach (unsubscribe) -> unsubscribe()
      l 2

    prevOff = thisComponent.fn.off
    thisComponent.fn.off = ->
      prevOff()
      unsubscribe()

    unsubscribe

  exports





exports.persons.on {}, (persons) ->
  exports.professors.set persons.filter ({type}) -> type is 'استاد'
  exports.deputies.set persons.filter ({type}) -> type is 'نماینده استاد'

exports.currentTerm.on {}, (currentTerm) ->
  [year, part] = currentTerm.split '-'
  terms = [].concat.apply [], [1390 .. year].map (year) ->
    ["#{year}-1", "#{year}-2"]
  if +part is 1
    terms.splice terms.length - 1, 1
  exports.terms.set terms