Q  = require 'q'
pg = require 'pg'
fs = require 'fs'

toPersian = (value) ->
  value = '' + value
  '۰۱۲۳۴۵۶۷۸۹'.split ''
  .forEach (digit, i) ->
    value = value.replace (new RegExp '' + i, 'g'), digit
  value.replace(/ي/g, 'ی').replace /ك/g, 'ک'

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

readFile = Qdenodify fs, fs.readFile
writeFile = Qdenodify fs, fs.writeFile

sql = null
sqlConnectedQ = Q().then ->
  client = new pg.Client 'postgres://dombak:dombak123@localhost/dombak'
  Q.all [client, Qdenodify(client, client.connect)()]
.then ([c]) ->
  Qdenodify c, c.query

sqlConnectedQ.then (query) ->

  readFile 'input.csv'
  .then (data) ->

    data = data.toString('utf8').split('\n')
    .filter (line) -> line.trim()
    .map (line) ->
      row = line.split(',').map (part) -> part.trim()
      courseNumber: +row[1]
      professorId: +row[6]

    Q.all data.map ({courseNumber, professorId}) ->

      query 'select "id" from "courses" where "number" = $1', [courseNumber]
      .then ({rows: [{id: courseId}]}) ->
        query 'insert into "offerings"("termId", "createdAt", "courseId", "professorId") values(\'1396-1\', NOW(), $1, $2)', [courseId, professorId]

      # queryQ = if professorId
      #   query 'select "id", "golestanNumber", "fullName" from "persons" where type=1 and "id" = $1', [professorId]
      # else if professorGolestanNumber
      #   query 'select "id", "golestanNumber", "fullName" from "persons" where type=1 and "golestanNumber" = $1', [professorGolestanNumber]
      # else
      #   professorNameParts = toPersian(professorName).replace(/\s\s+/g, ' ').split(' ').map((part) -> part.trim()).filter (part) -> part && (part not in ['دکتر', 'مهندس', 'خانم'])
      #   professorNamePartsExpression = professorNameParts.map (_, i) ->
      #     '"fullName" like ' + "'%' || $#{i+1} || '%'"
      #   .join ' or '
      #   if professorNameParts.length
      #     professorNamePartsExpression = ' and (' + professorNamePartsExpression + ')'
      #   query 'select "id", "golestanNumber", "fullName" from "persons" where type=1' + professorNamePartsExpression, professorNameParts

      # queryQ.then ({rows: professors}) ->
      #   professorConflicting = if professors.length != 1 then 'AAA' else ''
      #   foundProfessorNames = professors.map(({fullName}) -> fullName).join ' -- '
      #   foundProfessorGolestanNumbers = professors.map(({golestanNumber}) -> golestanNumber).join ' -- '
      #   foundProfessorIds = professors.map(({id}) -> id).join ' -- '
      #   {courseName, professorConflicting, professorName, foundProfessorNames, foundProfessorGolestanNumbers, foundProfessorIds}

# .then (data) ->

#   writeFile 'output.csv', data.map(({courseName, professorConflicting, professorName, foundProfessorNames, foundProfessorGolestanNumbers, foundProfessorIds}) ->
#     "#{courseName}, #{professorConflicting}, #{professorName}, #{foundProfessorNames}, #{foundProfessorGolestanNumbers}, #{foundProfessorIds}"
#   ).join '\n'

.then ->
  process.exit()
.done()
