
createSqlUtility = (client) ->
  sql = Qdenodify client, client.query
  sendQuery = (query, values) ->
    # console.log query, values if query.indexOf('INSERT') is 0
    sql query, values

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
    query = "INSERT INTO \"#{entity}\" (\"createdAt\", #{fields.map((field) -> '"' + field + '"').join(', ')}) VALUES (NOW(), #{(values.map -> '%').join(', ')})"
    query += " RETURNING \"id\"" if returnId
    getReturnObject query, values, 'id'

  update: (entity, data, predicate, returning) ->
    predicate = normalizePredicate predicate
    returning = objectifyArray returning
    fields = Object.keys data
    values = (fields.map (field) -> data[field]).concat predicate.values
    query = "UPDATE \"#{entity}\" SET \"updatedAt\" = NOW(), #{(fields.map (field) -> '"' + field + '"' + ' = %').join(', ')} WHERE \"deletedAt\" IS NULL AND #{predicate.query}"
    if returning?
      if typeof returning is 'string'
        returning = "\"#{returning}\""
      else
        r = Object.keys(returning)[0]
        returning = "\"#{returning[r]}\" AS \"#{r}\""
      query += " RETURNING #{returning}"
    getReturnObject query, values

  delete: (entity, predicate, returning) ->
    predicate = normalizePredicate predicate
    returning = objectifyArray returning
    query = "UPDATE \"#{entity}\" SET \"deletedAt\" = NOW() WHERE \"deletedAt\" IS NULL AND #{predicate.query}"
    query = "DELETE FROM \"#{entity}\" WHERE #{predicate.query}"
    if returning?
      if typeof returning is 'string'
        returning = "\"#{returning}\""
      else
        r = Object.keys(returning)[0]
        returning = "\"#{returning[r]}\" AS \"#{r}\""
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
    query += ' WHERE \"deletedAt\" IS NULL'
    if predicate?
      query += " AND #{predicate.query}"
      {values} = predicate
    else
      values = []
    getReturnObject query, values

  count: (entity, predicate) ->
    predicate = normalizePredicate predicate
    {values} = predicate
    query = "SELECT COUNT(*) AS cnt FROM \"#{entity}\" WHERE \"deletedAt\" IS NULL AND #{predicate.query}"
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