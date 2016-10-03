Q = require '../../q'
mock = require './mock'

module.exports = (isGet, serviceName, params = {}) ->

  if mock[serviceName]
    return mock[serviceName] params

  url = "/#{serviceName}"
  if isGet
    url += '?' + Object.keys(params).map((param) -> "#{param}=#{params[param]}").join '&'
  Q.promise (resolve, reject) ->
    xhr = new XMLHttpRequest()
    xhr.onreadystatechange = ->
      if xhr.readyState is 4
        if xhr.status is 200
          resolve JSON.parse xhr.responseText
        else
          reject xhr.responseText
    methodType = if isGet then 'GET' else 'POST'
    xhr.open methodType, url, true
    if isGet
      xhr.send()
    else
      xhr.setRequestHeader 'Content-Type', 'application/json'
      xhr.send JSON.stringify params