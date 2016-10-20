log = require('./log').dom
{toPersian, uppercaseFirst, extend, remove} = require '.'

exports.window = ->
  fn:
    name: 'window'
    element: window
    off: ->

exports.document = ->
  fn:
    name: 'document'
    element: document
    off: ->

exports.body = ->
  fn:
    name: 'body'
    element: document.body
    off: ->

exports.head = ->
  fn:
    name: 'head'
    element: document.head
    off: ->

exports.addPageCSS = (url) ->
  cssNode = document.createElement 'link'
  cssNode.setAttribute 'rel', 'stylesheet'
  cssNode.setAttribute 'href', "assets/#{url}"
  document.head.appendChild cssNode

exports.addPageStyle = (code) ->
  styleNode = document.createElement 'style'
  styleNode.type = 'text/css'
  styleNode.textContent = code
  document.head.appendChild styleNode

exports.generateId = do ->
  i = 0
  -> i++

exports.instance = (thisComponent) ->
  exports = {}

  exports.E = do ->
    e = (parent, tagName, style, children) ->
      element = document.createElement tagName
      component =
        value: -> element.value
        checked: -> element.checked
        focus: -> element.focus()
        blur: -> element.blur()
        select: -> element.select()
        fn:
          pInputListeners: []
          name: tagName
          element: element
          parent: parent
          off: ->
      exports.setStyle component, style
      do appendChildren = (children) ->
        children.forEach (x) ->
          if typeof(x) in ['string', 'number']
            exports.setStyle component, text: x
          else if Array.isArray x
            appendChildren x
          else
            exports.append component, x
      component

    (args...) ->
      firstArg = args[0]
      if typeof firstArg is 'function'
        l = log.E0 thisComponent
        restOfArgs = args[1..]
        l null, restOfArgs
        component = firstArg restOfArgs...
        component.fn.parent = thisComponent
        l component, restOfArgs
      else
        if typeof firstArg is 'string'
          tagName = firstArg
          style = args[1] or {}
          children = args[2..]
        else if typeof firstArg is 'object' and not Array.isArray firstArg
          tagName = 'div'
          style = firstArg or {}
          children = args[1..]
        else
          tagName = 'div'
          style = {}
          children = args[1..]
        l = log.E1 thisComponent, tagName, style, children, parent
        l()
        component = e thisComponent, tagName, style, children
        l()

      prevOff = thisComponent.fn.off
      thisComponent.fn.off = ->
        prevOff()
        component.fn.off()

      component

  exports.text = (text) ->
    l = log.text thisComponent, text
    l()
    component =
      fn:
        name: "text[#{text}]"
        element: document.createTextNode text
        off: ->
    l()
    component

  exports.append = (parent, component) ->
    unless component
      return
    if Array.isArray component
      return component.forEach (component) -> exports.append parent, component
    l = log.append thisComponent, parent, component
    l()
    parent.fn.element.appendChild component.fn.element
    component.fn.domParent = parent
    parent.fn.childComponents ?= []
    parent.fn.childComponents.push component
    l()

  exports.detatch = (component) ->
    if Array.isArray component
      return component.map (component) -> exports.detatch component
    {element} = component.fn
    l = log.detatch thisComponent, component
    l()
    element.parentNode.removeChild element
    remove component.fn.domParent.fn.childComponents, component
    l()

  exports.destroy = (component) ->
    if Array.isArray component
      return component.map (component) -> exports.destroy component
    l = log.destroy thisComponent, component
    l()
    exports.detatch component
    component.fn.off()
    l()

  exports.empty = (component) ->
    if Array.isArray component
      return component.map (component) -> exports.empty elemcomponentent
    {element} = component.fn
    l = log.empty thisComponent, component
    l()
    component.fn.childComponents?.slice().forEach exports.destroy
    l()

  exports.setStyle = (component, style = {}) ->
    if Array.isArray component
      return component.map (component) -> exports.setStyle component, style
    {element} = component.fn
    l = log.setStyle thisComponent, component, style, thisComponent
    l()
    component.fn.style = style
    Object.keys(style).forEach (key) ->
      value = style[key]
      switch key
        when 'html'
          element.innerHTML = toPersian value
        when 'englishHtml'
          element.innerHTML = value ? ''
        when 'text'
          element.textContent = element.innerText = toPersian value
        when 'englishText'
          element.textContent = element.innerText = value ? ''
        when 'value'
          unless element.value is toPersian value
            element.value = toPersian value
            setTimeout ->
              component.fn.pInputListeners.forEach (x) -> x {}
        when 'englishValue'
          unless element.value is value
            element.value = value ? ''
            setTimeout ->
              component.fn.pInputListeners.forEach (x) -> x {}
        when 'checked'
          element.checked = value
        when 'placeholder'
          element.setAttribute key, toPersian value
        when 'class', 'type', 'id', 'for', 'src', 'href', 'target'
          element.setAttribute key, value
        else
          if (typeof value is 'number') and not (key in ['opacity', 'zIndex'])
            value = Math.floor(value) + 'px'
          if (key is 'float')
            key = 'cssFloat'
          element.style[key] = value
    l()
    component

  exports.addClass = (component, klass) ->
    if Array.isArray component
      return component.map (component) -> exports.addClass component, klass
    if Array.isArray klass
      klass.forEach (klass) -> exports.addClass component, klass
      return component
    exports.removeClass component, klass
    {element} = component.fn
    l = log.addClass thisComponent, component, klass
    l()
    element.setAttribute 'class', ((element.getAttribute('class') ? '') + ' ' + klass).replace(/\ +/g, ' ').trim()
    l()
    component

  exports.removeClass = (component, klass) ->
    if Array.isArray component
      return component.map (component) -> exports.removeClass component, klass
    if Array.isArray klass
      klass.forEach (klass) -> exports.removeClass component, klass
      return component
    {element} = component.fn
    l = log.removeClass thisComponent, component, klass
    l()
    previousClass = (element.getAttribute 'class') ? ''
    classIndex = previousClass.indexOf klass
    if ~classIndex
      element.setAttribute 'class', ((previousClass.substr 0, classIndex) + (previousClass.substr classIndex + klass.length)).replace(/\ +/g, ' ').trim()
    l()
    component

  exports.show = (component) ->
    l = log.show thisComponent, component
    l()
    exports.removeClass component, 'hidden'
    l()
    component

  exports.hide = (component) ->
    l = log.hide thisComponent, component
    l()
    exports.addClass component, 'hidden'
    l()
    component

  exports.enable = (component) ->
    if Array.isArray component
      return component.map (component) -> exports.enable component
    {element} = component.fn
    l = log.enable thisComponent, component
    l()
    element.removeAttribute 'disabled'
    l()
    component

  exports.disable = (component) ->
    if Array.isArray component
      return component.map (component) -> exports.disable component
    {element} = component.fn
    l = log.disable thisComponent, component
    l()
    element.setAttribute 'disabled', 'disabled'
    l()
    component

  exports