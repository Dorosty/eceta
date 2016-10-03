
linear = (rawCallback, wrapCallback) ->
  
  lastX = undefined
  callback = (x) ->
    unless lastX is x
      lastX = x
      rawCallback x, (start, end) -> start + (end - start) * x

  x = 0
  running = false
  xStart = xDest = startTime = totalTime = undefined

  callback x
  
  animate = ->
    passedTime = performance.now() - startTime
    x = xStart + (xDest - xStart) * passedTime / totalTime

    if passedTime >= totalTime
      running = false
      callback xDest
    else
      callback x
      requestAnimationFrame animate

  (start, dest, time) ->
    xStart = x
    xDest = dest
    startTime = performance.now()
    totalTime = time * (xDest - xStart) / (dest - start)
    unless running or totalTime is 0
      running = true
      requestAnimationFrame animate

timeStep = 1 / 60
spring = ([k, m], rawCallback) ->
  
  lastX = undefined
  callback = (x) ->
    unless lastX is x
      lastX = x
      rawCallback x, running, (start, end) -> start + (end - start) * x
    
  x = xRest = 0
  v = 0
  running = false
  lastTime = undefined

  callback xRest

  animate = ->
    now = performance.now()
    deltaTime = now - lastTime
    stepsCount = Math.floor (deltaTime / 1000 / timeStep)
    lastTime = now
    for i in [0..stepsCount]
      a = -k * (x - xRest) - m * v
      v += a * timeStep
      x += v * timeStep
    remainingTime = ((deltaTime / 1000) - (stepsCount * timeStep))
    a = -k * (x - xRest) - m * v
    v += a * remainingTime
    x += v * remainingTime
    if Math.abs(a) <= 0.1
      running = false
      callback xRest
    else
      callback x
      requestAnimationFrame animate

  (arg, arg2) ->
    if typeof arg is 'function'
      rawCallback = arg
    else if typeof arg is 'object'
      [k, m] = arg
    else if arg2 is 'stretch'
      x = arg
      v = 0
      callback x
    else if arg2 is 'goto'
      x = xRest = arg
      v = 0
      running = false
      callback x
    else
      xRest = arg
      unless running
        running = true
        lastTime = performance.now()
        requestAnimationFrame animate


module.exports = {
  linear
  spring
}
