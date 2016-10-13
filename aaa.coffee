Q  = require 'q'
pg = require 'pg'
xlsx = require 'node-xlsx'
fs = require 'fs'

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

writeFile = Qdenodify fs, fs.writeFile

sqlConnectedQ.then ->
  sql.select ['persons', 'requestForAssistants', 'offerings'], [['fullName', 'email']],
    'x0.type = 2 AND x0.id = x1."studentId" AND x1."isTrained" = 0
    AND x1.status = 2 AND x1."offeringId" = x2.id AND x2."termId" = \'1395-1\''
  .then (persons) ->
    seen = {}
    persons = persons.filter (person) ->
      if seen[person.email]
        false
      else
        seen[person.email] = true
        true
    writeFile 'kargah narafte.xlsx', xlsx.build [name: 'sheet', data: persons.map ({fullName, email}) -> [fullName, email]]
.then ->
  process.exit()
.done()