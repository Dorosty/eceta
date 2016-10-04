unless module.dynamic

  clientDir = '../client'
  clientLoc = clientDir + '/index.coffee'

  req = require

  Q            = req 'q'
  http         = req 'http'
  express      = req 'express'
  bodyParser   = req 'body-parser'
  cookieParser = req 'cookie-parser'
  pg           = req 'pg'
  jwt          = req 'jsonwebtoken'
  crypto       = req 'crypto'
  nodemailer   = req 'nodemailer'
  fs           = req 'fs'
  request      = req 'request'

  Q.longStackSupport = true

  app = express()
  app.use bodyParser.json()
  app.use cookieParser()
  server = http.Server app
  server.listen 9090
  app.use '/assets', express.static clientDir + '/assets/'
  app.get '/', (req, res) ->
    res.send '
      <!doctype html>
      <html>
      <head>
      <title></title>
      <script src="assets/lib/shim.js"></script>
      <script src="assets/lib/sham.js"></script>
      <script src="assets/lib/platform.js"></script>
      <script src="assets/lib/jquery.js"></script>
      <script src="assets/lib/bootstrap.js"></script>
      </head>
      <body>
      <script src="assets/scripts.js"></script>
      </body>
      </html>
    '

  exports._data = {Q, http, express, bodyParser, cookieParser, pg, jwt, crypto, nodemailer, fs, request, app}
else
  {Q, http, express, bodyParser, cookieParser, pg, jwt, crypto, nodemailer, fs, request, app} = module._data
exports.Q = Q
exports.all = (promises) ->
  promises = promises.map (promise) ->
    promise?.catch? (e) -> error: e
  Q.all promises
  .then (results) ->
    error = undefined
    if (results.some (result) -> error = result?.error)
      throw error
    else
      return results

exports.server = server
exports.app    = app

convert = exports.convert =
  stringTypeToNumberType: (person) ->
    type = switch person.type
      when 'کارشناس آموزش' then 0
      when 'استاد' then 1
      when 'دانشجو' then 2
      when 'نماینده استاد' then 3
      else null
    extend person, {type}
  nubmerTypeToStringType: (person) ->
    type = switch +person.type
      when 0 then 'کارشناس آموزش'
      when 1 then 'استاد'
      when 2 then 'دانشجو'
      when 3 then 'نماینده استاد'
      else null
    extend person, {type}
  stringDegreeToNumberDegree: (person) ->
    degree = switch person.degree
      when 'کارشناسی' then 0
      when 'کارشناسی ارشد' then 1
      when 'دکتری' then 2
      else null
    extend person, {degree}
  numberDegreeToStringDegree: (person) ->
    degree = switch +person.degree
      when 0 then 'کارشناسی'
      when 1 then 'کارشناسی ارشد'
      when 2 then 'دکتری'
      else null
    unless person.degree?
      degree = null
    extend person, {degree}
  numberStatusToStringStatus: (requestForAssistant) ->
    status = switch +requestForAssistant.status
      when 0
        'در حال بررسی'
      when 1
        'رد شده'
      when 2
        'تایید شده'
    extend requestForAssistant, {status}
  stringStatusToNumberStatus: (requestForAssistant) ->
    status = switch requestForAssistant.status
      when 'در حال بررسی'
        0
      when 'رد شده'
        1
      when 'تایید شده'
        2
    extend requestForAssistant, {status}

exports.hash = (str) ->
  shasum = crypto.createHash 'sha1'
  shasum.update(str).digest 'hex'

toPersian = exports.toPersian = (value) ->
  value = '' + value
  '۰۱۲۳۴۵۶۷۸۹'.split ''
  .forEach (digit, i) ->
    value = value.replace (new RegExp '' + i, 'g'), digit
  value.replace(/ي/g, 'ی').replace /ك/g, 'ک'
exports.sendMail = (email, subject, text, name, html) ->
  ##################
  email = 'ma.dorosty@gmail.com'
  ##################
  name = toPersian name
  subject = toPersian subject
  name ?= email
  mailServer = nodemailer.createTransport
    host: 'mail.ut.ac.ir',
    auth:
      user: 'ma.dorosty',
      pass: 'Ma19Md93M'
  message = {
    from: 'سامانه مدیریت دستیاران آموزشی <ma.dorosty@ut.ac.ir>'
    to: "#{name} <#{email}>"
    subject
    text
  }
  if html?
    message.html = "<div dir=\"rtl\">#{html}</div>"
  (Qdenodify mailServer, mailServer.sendMail) message

exports.randomString = (stringLength) ->
  chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  res = ''
  for i in [1..stringLength]
    rnum = Math.floor(Math.random() * chars.length)
    res += chars.substring rnum, rnum + 1
  res

exports.jalaali = do ->
  toJalaali = (gy, gm, gd) -> d2j(g2d(gy, gm, gd))
  toGregorian = (jy, jm, jd) -> d2g(j2d(jy, jm, jd))
  isValidJalaaliDate = (jy, jm, jd) -> jy >= -61 && jy <= 3177 && jm >= 1 && jm <= 12 && jd >= 1 && jd <= jalaaliMonthLength(jy, jm)
  isLeapJalaaliYear = (jy) -> jalCal(jy).leap is 0
  jalaaliMonthLength = (jy, jm) ->
    return 31 if (jm <= 6)
    return 30 if (jm <= 11)
    return 30 if (isLeapJalaaliYear(jy))
    return 29
  jalCal = (jy) ->
    breaks =  [-61, 9, 38, 199, 426, 686, 756, 818, 1111, 1181, 1210, 1635, 2060, 2097, 2192, 2262, 2324, 2394, 2456, 3178]
    bl = breaks.length
    gy = jy + 621
    leapJ = -14
    jp = breaks[0]
    jm = jump = leap = leapG = march = n = i = null
    if (jy < jp || jy >= breaks[bl - 1])
      throw new Error('Invalid Jalaali year ' + jy)
    i = 1
    while (i < bl)
      jm = breaks[i]
      jump = jm - jp
      if (jy < jm)
        break
      leapJ = leapJ + div(jump, 33) * 8 + div(mod(jump, 33), 4)
      jp = jm
      i += 1
    n = jy - jp
    leapJ = leapJ + div(n, 33) * 8 + div(mod(n, 33) + 3, 4)
    if (mod(jump, 33) is 4 && jump - n is 4)
      leapJ += 1
    leapG = div(gy, 4) - div((div(gy, 100) + 1) * 3, 4) - 150
    march = 20 + leapJ - leapG
    if (jump - n < 6)
      n = n - jump + div(jump + 4, 33) * 33
    leap = mod(mod(n + 1, 33) - 1, 4)
    if (leap is -1) 
      leap = 4
    {leap, gy, march}
  j2d = (jy, jm, jd) ->
    r = jalCal(jy)
    g2d(r.gy, 3, r.march) + (jm - 1) * 31 - div(jm, 7) * (jm - 7) + jd - 1
  d2j = (jdn) ->
    gy = d2g(jdn).gy
    jy = gy - 621
    r = jalCal(jy)
    jdn1f = g2d(gy, 3, r.march)
    jd = jm = k = null
    k = jdn - jdn1f
    if (k >= 0)
      if (k <= 185)
        jm = 1 + div(k, 31)
        jd = mod(k, 31) + 1
        return {jy, jm, jd}
      else
        k -= 186
    else
      jy -= 1
      k += 179
      if (r.leap is 1)
        k += 1
    jm = 7 + div(k, 30)
    jd = mod(k, 30) + 1
    return {jy, jm, jd}
  g2d = (gy, gm, gd) ->
    d = div((gy + div(gm - 8, 6) + 100100) * 1461, 4) + div(153 * mod(gm + 9, 12) + 2, 5)+ gd - 34840408
    d = d - div(div(gy + 100100 + div(gm - 8, 6), 100) * 3, 4) + 752
    return d
  d2g = (jdn) ->
    j = 4 * jdn + 139361631
    j = j + div(div(4 * jdn + 183187720, 146097) * 3, 4) * 4 - 3908
    i = div(mod(j, 1461), 4) * 5 + 308
    gd = div(mod(i, 153), 5) + 1
    gm = mod(div(i, 153), 12) + 1
    gy = div(j, 1461) - 100100 + div(8 - gm, 6)
    {gy, gm, gd}
  div = (a, b) -> ~~(a / b)
  mod = (a, b) -> a - ~~(a / b) * b  
  {
    toJalaali
    toGregorian
    isValidJalaaliDate
    isLeapJalaaliYear
    jalaaliMonthLength
    jalCal
    j2d
    d2j
    g2d
    d2g
  }

extend = exports.extend = (target, sources...) ->
  sources.forEach (source) ->
    Object.keys(source).forEach (key) ->
      value = source[key]
      unless key is 'except'
        target[key] = value
      else
        if Array.isArray value
          value.forEach (k) -> delete target[k]
        else if typeof value is 'object'
          Object.keys(value).forEach (k) -> delete target[k]
        else
          delete target[value]
  target

Qdenodify = exports.Qdenodify = (owner, fn) ->
  (args...) ->
    Q.promise (resolve, reject) ->
      args.push (err, results...) ->
        if err?
          reject err
        else if results.length is 0
          resolve undefined
        else if results.length is 1
          resolve results[0]
        else
          resolve results
      try
        fn.apply owner, args
      catch err
        reject err

exports.readFile   = Qdenodify fs, fs.readFile
exports.requestGet = Qdenodify request, request.get

sqlNameCache = do ->
  queryNames = {}
  id = 0
  generateName = -> 'query' + (id++)
  return (query) ->
    queryNames[query] ?= generateName()
    queryNames[query]

createSqlUtility = (client) ->
  sql = Qdenodify client, client.query
      
  sendQuery = (query, values) ->
    sql name: sqlNameCache(query), text: query, values: values

  normalizePredicate = (predicate) ->
    return null unless predicate?
    if typeof predicate is 'string'
      return query: predicate, values: []
    if typeof predicate.query is 'string'
      unless predicate.values? and Array.isArray predicate.values
        predicate.values = []
      return predicate
    fields = Object.keys predicate
    values = fields.map (field) -> predicate[field]
    query = fields.map (field, i) ->
      "\"#{field}\" = %"
    .join ' AND '
    {query, values}

  objectifyArray = (x) ->
    if Array.isArray x
      x.reduce ((result, y) ->
        result[y] = y
        result
      ), {}
    else
      x

  finalizeQuery = (query, values) ->
    values.forEach (_, i) ->
      placeholder = "$#{i + 1}"
      index = query.indexOf '%'
      if !~query.indexOf(placeholder) and ~index
        query = query.substr(0, index) + placeholder + query.substr index + 1
    query

  getReturnObject = (query, values, field) ->
    finalizedQuery = finalizeQuery query, values
    deferred = Q.defer()
    timeout = setTimeout ->
      sendQuery finalizedQuery, values
      .then (({rows}) ->
        if field?
          deferred.resolve rows[0]?[field]
        else
          deferred.resolve rows
      ), deferred.reject
    promise = deferred.promise
    promise.unsend = ->
      clearTimeout timeout
      deferred.resolve null
    Object.defineProperty promise, 'query',
      get: ->
        promise.unsend()
        query
    Object.defineProperty promise, 'finalizedQuery',
      get: ->
        promise.unsend()
        finalizedQuery
    Object.defineProperty promise, 'values',
      get: ->
        promise.unsend()
        values
    promise

  insert: (entity, data, returnId = false) ->
    fields = Object.keys data
    values = fields.map (field) -> data[field]
    query = "INSERT INTO \"#{entity}\" (\"createdAt\" #{if fields.length then ',' else ''} #{fields.map((field) -> '"' + field + '"').join(', ')}) VALUES (NOW() #{if values.length then ',' else ''} #{(values.map -> '%').join(', ')})"
    query += " RETURNING \"id\"" if returnId
    getReturnObject query, values, 'id'

  update: (entity, data, predicate, returning) ->
    predicate = normalizePredicate predicate
    returning = objectifyArray returning
    fields = Object.keys data
    values = (fields.map (field) -> data[field]).concat predicate.values
    query = "UPDATE \"#{entity}\" SET \"updatedAt\" = NOW(), #{(fields.map (field) -> '"' + field + '"' + ' = %').join(', ')} WHERE #{predicate.query}"
    if returning?
      if typeof returning is 'string'
        returning = "\"#{returning}\""
      else
        returning = (Object.keys(returning).map (r) -> "\"#{returning[r]}\" AS \"#{r}\"").join ', '
      query += " RETURNING #{returning}"
    getReturnObject query, values

  delete: (entity, predicate, returning) ->
    predicate = normalizePredicate predicate
    returning = objectifyArray returning
    query = "UPDATE \"#{entity}\" SET \"deletedAt\" = NOW() WHERE #{predicate.query}" ##################################
    query = "DELETE FROM \"#{entity}\" WHERE #{predicate.query}"
    if returning?
      if typeof returning is 'string'
        returning = "\"#{returning}\""
      else
        returning = (Object.keys(returning).map (r) -> "\"#{returning[r]}\" AS \"#{r}\"").join ', '
      query += " RETURNING #{returning}"
    getReturnObject query, predicate.values

  select: select = (entities, fieldss, predicate) ->
    predicate = normalizePredicate predicate
    unless Array.isArray entities
      entities = [entities]
      fieldss = [fieldss]
    allFields = entities.map (_, i) ->
      fields = fieldss[i]
      return null unless fields?
      fields = objectifyArray fields
      if typeof fields is 'string'
        unless fields is '*'
          fields = "x#{i}.\"#{fields}\" AS \"#{fields}\""
        else
          fields = "x#{i}.*"
      else
        fields = Object.keys(fields).map (field) ->
          "x#{i}.\"#{fields[field]}\" AS \"#{field}\""
        .join ', '
      fields
    .filter (fields) -> fields?
    .join ', '
    query = "SELECT #{allFields} FROM #{(entities.map (entity, i) -> '"' + entity + '" x' + i).join(', ')}"
    if predicate?
      query += " WHERE #{predicate.query}"
      {values} = predicate
    else
      values = []
    getReturnObject query, values

  count: (entity, predicate) ->
    predicate = normalizePredicate predicate
    {values} = predicate
    query = "SELECT COUNT(*) AS cnt FROM \"#{entity}\" WHERE #{predicate.query}"
    getReturnObject query, values, 'cnt'

  exists: (entities, predicate) ->
    entities = [entities] unless Array.isArray entities
    {query, values} = select entities, (entities.map -> '*'), predicate
    query = "SELECT EXISTS(#{query}) AS ex"
    getReturnObject query, values, 'ex'

  query: (query, values) ->
    unless Array.isArray values
      values = []
    sendQuery query, values

dbPool = new pg.Pool {
  user: 'dombak'
  database: 'dombak'
  password: 'dombak123'
  port: 5432
  max: 10
  idleTimeoutMillis: 30000
}
dbPoolConnect = Qdenodify dbPool, dbPool.connect

jwtSecret = '123456dombakVeryVerySecretKey123456'
jwtOptions = expiresIn: 60 * 60

logStream = fs.createWriteStream 'log.txt', flags: 'a'
onExit = ->
  logStream.end()
  process.exit()
process.on 'exit', onExit
process.on 'SIGINT', onExit
process.on 'uncaughtException', onExit
configResponse = undefined
handle = (methodName) -> (route, handler) ->
  route = '/' + route
  appRoute = app._router.stack.filter (x) -> x.route?.path is route
  if appRoute.length > 0
    appRoute = appRoute[0]
    app._router.stack.splice app._router.stack.indexOf(appRoute), 1
  app[methodName] route, (req, res) ->
    delete req.query.rand
    extend req.body, req.query
    dbPoolConnect().then ([client, done]) ->
      sql = createSqlUtility client
      query = Qdenodify client, client.query
      query 'BEGIN'
      .then ->
        try
          {personId} = jwt.verify req.cookies.id, jwtSecret
          extend personId, except: ['iat', 'exp']
          extend req, {personId}
        catch
          req.loggedOut = true
        try
          {data} = jwt.verify req.cookies.data, jwtSecret
          extend data, except: ['iat', 'exp']
          extend req, {data}
        handler sql, req
      .then (response) ->
        response ?= {}
        if Array.isArray(response) or typeof response isnt 'object'
          response = value: response

        if response.setPersonId
          personId = response.setPersonId
        else if req.personId
          personId = req.personId
        else if req.loggedOut
          response.loggedOut = true
        delete response.setPersonId

        if response.setData
          data = response.setData
        else if req.data
          data = req.data
        else
          data = {}
        delete response.setData

        if personId
          res.cookie 'id', jwt.sign {personId}, jwtSecret, jwtOptions
        if data
          res.cookie 'data', jwt.sign {data}, jwtSecret, jwtOptions
        Q configResponse methodName, personId, response, sql, req
        .then -> response
      .then (response) ->
        query if response.error then 'ROLLBACK' else 'COMMIT'
        .then ->
          done()
          res.json response
          response = extend {}, response
          Object.keys(response).forEach (key) ->
            if Array.isArray response[key]
              response[key] = "[#{response[key].length} items]"
          logStream.write "#{new Date()}\n#{route}\n#{JSON.stringify req.body}\n#{JSON.stringify response}\n\n\n"
      .catch (error) ->
        query 'ROLLBACK'
        .then ->
          done()
          res.status(400).send if error?.error then error.error else ''
          logStream.write "ERROR: #{new Date()}\n#{route}\n#{JSON.stringify req.body}\n#{error}\n\n"
          try
            logStream.write "ERROR: #{new Date()}\n#{route}\n#{JSON.stringify req.body}\n#{JSON.stringify error}\n\n\n"

exports.config = (x) -> configResponse = x
exports.get = handle 'get'
exports.post = handle 'post'
