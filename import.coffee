Q  = require 'q'
pg = require 'pg'
nodemailer = require 'nodemailer'

Q.longStackSupport = true

Qdenodify = (owner, fn) ->
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

createSqlUtility = (client) ->
  sql = Qdenodify client, client.query

  sqlNameCache = do ->
    queryNames = {}
    id = 0
    generateName = -> 'query' + (id++)
    return (query) ->
      queryNames[query] ?= generateName()
      queryNames[query]
      
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

sql = null
sqlConnectedQ = Q().then ->
  client = new pg.Client 'postgres://dombak:dombak123@localhost/dombak'
  Q.all [client, Qdenodify(client, client.connect)()]
.then ([c]) ->
  sql = createSqlUtility c

toPersian = (value) ->
  value = '' + value
  '۰۱۲۳۴۵۶۷۸۹'.split ''
  .forEach (digit, i) ->
    value = value.replace (new RegExp '' + i, 'g'), digit
  value.replace(/ي/g, 'ی').replace /ك/g, 'ک'

sendMail = (email, subject, text, name, html) ->
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

sqlConnectedQ.then ->
  sql.select ['offerings', 'courses'], [['id', 'courseId'], ['name']],
    query: 'x0."termId" = \'1395-2\' and x0."courseId" = x1.id'
  .then (offerings) ->
    Q.all offerings.map ({id, courseId, name}) ->
      Q.all [
        sql.insert 'requiredCourses', {courseId, offeringId: id}
        sql.select ['persons', 'requestForAssistants'], [['email', 'fullName']],
          query: 'x1."offeringId"=% and x0.id=x1."studentId"', values: [id]
        .then (persons) ->
          return
          Q.all persons.map ({fullName, email}) ->
            sendMail email, 'تغییر لیست دروس مورد نیاز',
              "دانشجوی گرامی،\n
              \n
              با سلام\n
              \n
              لیست درس‌های مورد نیاز برای درس «#{toPersian name}» تغییر کرده است. لطفا در اسرع وقت درخواست خود را ویرایش کنید.\n
              \n
              سامانه مدیریت دستیاران آموزشی\n
              دانشکده مهندسی برق و کامپیوتر\n
              <a href=\"http://eceta.ut.ac.ir\">http://eceta.ut.ac.ir</a>",
              fullName,
              "دانشجوی گرامی،<br />
              <br />
              با سلام<br />
              <br />
              لیست درس‌های مورد نیاز برای درس «#{toPersian name}» تغییر کرده است. لطفا در اسرع وقت درخواست خود را ویرایش کنید.<br />
              <br />
              سامانه مدیریت دستیاران آموزشی<br />
              دانشکده مهندسی برق و کامپیوتر<br />
              <a href=\"http://eceta.ut.ac.ir\">http://eceta.ut.ac.ir</a>"
      ]

.then ->
  process.exit()
.done()