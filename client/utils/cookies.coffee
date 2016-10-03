
createCookie = (name, value, days) ->
  if days
    date = new Date()
    date.setTime +date + (days * 24 * 60 * 60 * 1000)
    expires = "; expires=#{date.toGMTString()}"
  else
    expires = ''
  document.cookie = "#{name}=#{value}#{expires}; path=/"

readCookie = (name) ->
  nameEQ = "#{name}="
  resultArray = document.cookie.split ';'
  .map (c) ->
    while c.charAt(0) is ' '
      c = c.substring 1, c.length
    c
  .filter (c) ->
    c.indexOf(nameEQ) is 0
  [result] = resultArray
  result?.substring nameEQ.length

eraseCookie = (name) ->
  createCookie name, '', -1


module.exports = {
  createCookie
  readCookie
  eraseCookie
}
