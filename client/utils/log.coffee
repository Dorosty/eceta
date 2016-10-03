log = (x) ->
  # return
  console.log x

getFullName = (component) ->
  name = ''
  while component
    name = "#{component.fn.name}>#{name}"
    component = component.parent
  name.substr 0, name.length - 1

exports.component =
  create: (part, component) ->
    return
    log "#{part}:create:#{getFullName component}"

exports.dom =
  E0: (thisComponent) ->
    part = 0
    (component, args) ->
      return
      try
        stringifiedArgs = JSON.stringify args
      catch
        stringifiedArgs = '[Cannot Stringify]'
      log "#{part++}:dom.E:#{if component then getFullName component else 'UnknownComponent'}#{if args.length then ':' + stringifiedArgs else ''}|#{getFullName thisComponent}"
      

  E1: (thisComponent, tagName, style, children) ->
    logText = "dom.E:#{getFullName fn: {name: tagName, parent: thisComponent}}"
    if Object.keys(style).length
      logText += ':' + JSON.stringify style
    if children.length
      logText += ':HasChildren' 
    logText += "|#{getFullName thisComponent}"
    part = 0
    ->
      return
      log "#{part++}:#{logText}"

  text: (thisComponent, text) ->
    part = 0
    ->
      return
      log "#{part++}:dom.text:#{text}|#{getFullName thisComponent}"

  append: (thisComponent, parent, component) ->
    part = 0
    ->
      return
      log "#{part++}:dom.append:#{getFullName parent}--->#{getFullName component}|#{getFullName thisComponent}"

  detatch: (thisComponent, component) ->
    part = 0
    ->
      return
      log "#{part++}:dom.detatch:#{getFullName component}|#{getFullName thisComponent}"

  destroy: (thisComponent, component) ->
    part = 0
    ->
      return
      log "#{part++}:dom.destroy:#{getFullName component}|#{getFullName thisComponent}"

  empty: (thisComponent, component) ->
    part = 0
    ->
      return
      log "#{part++}:dom.empty:#{getFullName component}|#{getFullName thisComponent}"

  setStyle: (thisComponent, component, style) ->
    logText = "dom.setStyle:#{getFullName component}"
    if Object.keys(style).length
      logText += ':' + JSON.stringify style
    logText += "|#{getFullName thisComponent}"
    part = 0
    ->
      return
      log "#{part++}:#{logText}"

  addClass: (thisComponent, component, klass) ->
    part = 0
    ->
      return
      log "#{part++}:dom.addClass:#{getFullName component}:#{klass}|#{getFullName thisComponent}"

  removeClass: (thisComponent, component, klass) ->
    part = 0
    ->
      return
      log "#{part++}:dom.removeClass:#{getFullName component}:#{klass}|#{getFullName thisComponent}"

  show: (thisComponent, component) ->
    part = 0
    ->
      return
      log "#{part++}:dom.show:#{getFullName component}|#{getFullName thisComponent}"

  hide: (thisComponent, component) ->
    part = 0
    ->
      return
      log "#{part++}:dom.hide:#{getFullName component}|#{getFullName thisComponent}"

  enable: (thisComponent, component) ->
    part = 0
    ->
      return
      log "#{part++}:dom.enable:#{getFullName component}|#{getFullName thisComponent}"

  disable: (thisComponent, component) ->
    part = 0
    ->
      return
      log "#{part++}:dom.disable:#{getFullName component}|#{getFullName thisComponent}"

exports.events =
  onEvent: (thisComponent, component, event, ignores, callback) ->
    logText = "events.onEvent:#{getFullName component}:#{event}"
    if ignores
      logText += ":ignore:#{JSON.stringify ignores.map (component) -> getFullName component}"
    logText += "|#{getFullName thisComponent}"
    parts = [0, 0, 0]
    l = (partIndex, e) ->
      return
      log "#{partIndex}:#{parts[partIndex]++}#{if e then ':' + JSON.stringify e else ''}:#{logText}"
    l.ignore = (ignoredComponent, e) ->
      return
      log "ignore #{getFullName ignoredComponent}#{if e then ':' + JSON.stringify e else ''}:#{logText}"
    l

  onLoad: (thisComponent, callback) ->
    parts = [0, 0, 0]
    (partIndex) ->
      return
      log "#{partIndex}:#{parts[partIndex]++}:events.onLoad|#{getFullName thisComponent}"

  onResize: (thisComponent, callback) ->
    parts = [0, 0, 0]
    (partIndex) ->
      return
      log "#{partIndex}:#{parts[partIndex]++}:events.onResize|#{getFullName thisComponent}"

  onMouseover: (thisComponent, component, callback) ->
    parts = [0, 0, 0]
    (partIndex) ->
      return
      log "#{partIndex}:#{parts[partIndex]++}:events.onMouseover:#{getFullName component}|#{getFullName thisComponent}"

  onMouseout: (thisComponent, component, callback) ->
    parts = [0, 0, 0]
    (partIndex) ->
      return
      log "#{partIndex}:#{parts[partIndex]++}:events.onMouseout:#{getFullName component}|#{getFullName thisComponent}"

  onMouseup: (thisComponent, callback) ->
    parts = [0, 0, 0]
    (partIndex) ->
      return
      log "#{partIndex}:#{parts[partIndex]++}:events.onMouseup|#{getFullName thisComponent}"

  onEnter: (thisComponent, component, callback) ->
    parts = [0, 0, 0]
    (partIndex) ->
      return
      log "#{partIndex}:#{parts[partIndex]++}:events.onEnter:#{getFullName component}|#{getFullName thisComponent}"

exports.state =
  createPubsub: (thisComponent) ->
    on: (options, callback) ->
      parts = [0, 0, 0]
      (partIndex, data) ->
        return
        logText = "#{partIndex}:#{parts[partIndex]++}:state.createPubsub.on:#{JSON.stringify options}"
        if partIndex is 1
          logText += ':' + JSON.stringify data
        logText += "|#{getFullName thisComponent}"
        log logText
    set: (data) ->
      part = 0
      ->
        return
        log "#{part++}:state.createPubsub.set:#{JSON.stringify data}|#{getFullName thisComponent}"

  pubsub: (thisComponent, name) ->
    on: (options, callback) ->
      parts = [0, 0, 0]
      (partIndex, data) ->
        return
        logText = "#{partIndex}:#{parts[partIndex]++}:state.pubsub.on:#{name}:#{JSON.stringify options}"
        if partIndex is 1
          logText += ':' + JSON.stringify data
        logText += "|#{getFullName thisComponent}"
        log logText
    set: (data) ->
      part = 0
      ->
        return
        log "#{part++}:state.pubsub.set:#{name}:#{JSON.stringify data}|#{getFullName thisComponent}"

  all: (thisComponent, options, keys, callback) ->
    parts = [0, 0, 0]
    (partIndex, data) ->
      return
      log "#{partIndex}:#{parts[partIndex]++}:state.all:#{JSON.stringify keys}:#{JSON.stringify options}#{if data then ':' + JSON.stringify data else ''}|#{getFullName thisComponent}"

exports.service =
  get: (thisComponent, url, params) ->
    (data) ->
      return
      log "service.get:#{url}#{if params then ':' + JSON.stringify params else ''}#{if data then ':' + JSON.stringify data else ''}|#{getFullName thisComponent}"

  post: (thisComponent, url, params) ->
    (data) ->
      return
      log "service.post:#{url}#{if params then ':' + JSON.stringify params else ''}#{if data then ':' + JSON.stringify data else ''}|#{getFullName thisComponent}"
