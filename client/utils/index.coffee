exports.compare = (a, b) ->
  if a > b
    1
  else if a < b
    -1
  else 0

exports.remove = (array, item) ->
  index = array.indexOf item
  if ~index
    array.splice index, 1
  array

exports.extend = (target, sources...) ->
  sources.forEach (source) ->
    Object.keys(source).forEach (key) ->
      target[key] = source[key]
  target

exports.uppercaseFirst = (name) ->
  name.charAt(0).toUpperCase() + name.substr 1

exports.toEnglish = (value) ->
  value ?= ''
  value = '' + value
  '۰۱۲۳۴۵۶۷۸۹'.split ''
  .forEach (digit, i) ->
    value = value.replace (new RegExp digit, 'g'), i
  value.replace '/', '.'

exports.toPersian = (value) ->
  value ?= ''
  value = '' + value
  '۰۱۲۳۴۵۶۷۸۹'.split ''
  .forEach (digit, i) ->
    value = value.replace (new RegExp '' + i, 'g'), digit
  value.replace(/ي/g, 'ی').replace /ك/g, 'ک'

exports.toDate = (timestamp) ->
  date = new Date timestamp
  day = date.getDate()
  month = date.getMonth() + 1
  year = date.getFullYear()
  j = jalaali.toJalaali year, month, day
  day = j.jd
  month = j.jm
  year = j.jy
  String(year).substr(2) + '/' + month + '/' + day

exports.textIsInSearch = (text, search, notPersian, caseSensitive) ->
  unless notPersian
    text = exports.toPersian text
    search = exports.toPersian search
  unless caseSensitive
    text = text.toLowerCase()
    search = search.toLowerCase()
  searchWords = search.trim().split ' '
  .map (x) -> x.trim()
  .filter (x) -> x
  textWords = text.trim().split ' '
  .map (x) -> x.trim()
  .filter (x) -> x
  searchWords.every (searchWord) ->
    textWords.some (textWord) ->
      ~textWord.indexOf searchWord

exports.collection = (add, destroy, change) ->
  data = []
  (newData) ->
    if newData.length > data.length
      if data.length
        [0 .. data.length - 1].forEach (i) ->
          data[i] = change newData[i], data[i]
      [data.length .. newData.length - 1].forEach (i) ->
        data[i] = add newData[i]
    else if data.length > newData.length
      if newData.length
        [0 .. newData.length - 1].forEach (i) ->
          data[i] = change newData[i], data[i]
      while data.length > newData.length
        destroy data[data.length - 1]
        data.splice (data.length - 1), 1
    else if data.length
      [0 .. data.length - 1].forEach (i) ->
        data[i] = change newData[i], data[i]