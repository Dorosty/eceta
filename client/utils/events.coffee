log = require('./log').events
{window, body} = require './dom'
{remove} = require '.'

isIn = (component, {pageX, pageY}) ->
  rect = component.fn.element.getBoundingClientRect()
  minX = rect.left
  maxX = rect.left + rect.width
  minY = rect.top + window().fn.element.scrollY
  maxY = rect.top + window().fn.element.scrollY + rect.height
  minX < pageX < maxX and minY < pageY < maxY

exports.instance = (thisComponent) ->
  exports = {}

  exports.onEvent = (args...) ->
    switch args.length
      when 3
        [component, event, callback] = args
      when 4
        [component, event, ignores, callback] = args
        unless Array.isArray ignores
          ignores = [ignores]

    if Array.isArray component
      unbinds = component.map (component) ->
        args[0] = component
        exports.onEvent.apply null, args
      return -> unbinds.forEach (unbind) -> unbind()
    if Array.isArray event
      unbinds = event.map (event) ->
        args[1] = event
        exports.onEvent.apply null, args
      return -> unbinds.forEach (unbind) -> unbind()

    {element} = component.fn

    l = log.onEvent thisComponent, component, event, ignores, callback

    callback = do (callback) -> (e) ->
      e.target ?= e.srcElement
      if ignores
        target = e.target
        while target and target isnt document and target isnt document.body
          shouldIgnore = ignores.some (ignore) ->
            if target is ignore.fn.element
              l.ignore ignore, e
              return true
          if shouldIgnore
            return
          target = target.parentNode or target.parentElement
      l 1, e
      callback e
      l 1, e

    l 0
    if event is 'pInput'
      component.fn.pInputListeners.push callback
    else if element.addEventListener
      element.addEventListener event, callback
    else if element.attachEvent
      element.attachEvent "on#{uppercaseFirst event}", callback
    l 0

    unbind = ->
      l 2
      if event is 'pInput'
        remove component.fn.pInputListeners, callback
      else if element.removeEventListener
        element.removeEventListener event, callback
      else if element.detachEvent
        element.detachEvent "on#{uppercaseFirst event}", callback
      l 2

    prevOff = component.fn.off
    component.fn.off = ->
      prevOff()
      unbind()

    unbind

  exports.onLoad = (callback) ->
    l = log.onLoad thisComponent, callback
    l 0
    unbind = exports.onEvent window(), 'load', (e) ->
      l 1, e
      callback e
      l 1, e
    l 0
    ->
      l 2
      unbind()
      l 2

  exports.onResize = (callback) ->
    l = log.onResize thisComponent, callback
    l 0
    unbind = exports.onEvent window(), 'resize', (e) ->
      l 1, e
      callback e
      l 1, e
    l 0
    ->
      l 2
      unbind()
      l 2

  exports.onMouseover = (component, callback) ->
    l = log.onMouseover thisComponent, component, callback
    allreadyIn = false
    l 0
    unbind = exports.onEvent body(), 'mousemove', (e) ->
      if isIn component, e
        l 1, e
        callback e unless allreadyIn
        l 1, e
        allreadyIn = true
      else
        allreadyIn = false
    l 0
    ->
      l 2
      unbind()
      l 2

  exports.onMouseout = (component, callback) ->
    l = log.onMouseout thisComponent, component, callback
    allreadyOut = false
    if component
      l 0.0
      unbind0 = exports.onEvent body(), 'mousemove', (e) ->
        unless isIn component, e
          l 1.0, e
          callback e unless allreadyOut
          l 1.0, e
          allreadyOut = true
        else
          allreadyOut = false
      l 0.0
    l 0.1
    unbind1 = exports.onEvent body(), 'mouseout', (e) ->
      from = e.relatedTarget || e.toElement
      if !from || from.nodeName == 'HTML'
        l 1.1, e
        allreadyOut = true
        callback e
        l 1.1, e
    l 0.1
    ->
      l 2.0
      unbind0?()
      l 2.0
      l 2.1
      unbind1()
      l 2.1

  exports.onMouseup = (callback) ->
    l 0.0
    unbind0 = exports.onEvent body(), 'mouseup', (e) ->
      l 1.0, e
      callback e
      l 1.0, e
    l 0.0
    l 0.1
    unbind1 = exports.onEvent body(), 'mouseout', (e) ->
      from = e.relatedTarget || e.toElement
      if !from || from.nodeName == 'HTML'
        l 1.1, e
        callback e
        l 1.1, e
    l 0.1
    ->
      l 2.0
      unbind0()
      l 2.0
      l 2.1
      unbind1()
      l 2.1

  exports.onEnter = (component, callback) ->
    l = log.onEnter thisComponent, component, callback
    l 0
    unbind = exports.onEvent component, 'keydown', (e) ->
      if e.keyCode is 13
        l 1, e
        callback()
        l 1, e
    l 0
    ->
      l 2
      unbind()
      l 2

  exports