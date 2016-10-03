{config, get, post, requestGet, Q, readFile, hash, sendMail, extend, randomString, jalaali, convert, all, toPersian} = require './utils'

post 'openAllOfferings', (sql) ->
  sql.query 'UPDATE offerings SET "isClosed" = 0'

post 'reportBug', (sql, req) ->
  {description, platform, person} = req.body
  sendMail 'ma.dorosty@gmail.com', 'گزارش خطا', "#{description}\n\n\n#{person}\n\n\n#{platform}", 'Ali Dorosty'
  null

sendEmail = (email, name) ->
  register: (email, verificationCode) ->
    link = "http://eceta.ut.ac.ir?email=#{email}&verificationCode=#{verificationCode}"
    sendMail email, 'تایید عضویت',
                    "کاربر گرامی،\n
                    \n
                    با سلام\n
                    \n
                    ضمن تشکر از اقدام برای عضویت در سامانه مدیریت دستیاران آموزشی، خواهشمند است با کلیک روی پیوند زیر عضویت خود را در این سامانه تایید نمایید.\n
                    #{link}\n
                    \n
                    سامانه مدیریت دستیاران آموزشی\n
                    دانشکده مهندسی برق و کامپیوتر\n
                    http://eceta.ut.ac.ir",
                    name,
                    "کاربر گرامی،<br />
                    <br />
                    با سلام
                    <br />
                    ضمن تشکر از اقدام برای عضویت در سامانه مدیریت دستیاران آموزشی، خواهشمند است با کلیک روی پیوند زیر عضویت خود را در این سامانه تایید نمایید.<br />
                    <a href=\"#{link}\">#{link}</a><br />
                    <br />
                    سامانه مدیریت دستیاران آموزشی<br />
                    دانشکده مهندسی برق و کامپیوتر<br />
                    <a href=\"http://eceta.ut.ac.ir\">http://eceta.ut.ac.ir</a>"
    return null

  requestForAssistantSent: (courseName) ->
    sendMail email, 'درخواست دستیاری با موفقیت ارسال شد',
                    "دانشجوی گرامی،\n
                    \n
                    با سلام\n
                    \n
                    درخواست شما برای دستیاری در درس «#{toPersian courseName}» با موفقیت ارسال شد.\n
                    \n
                    سامانه مدیریت دستیاران آموزشی\n
                    دانشکده مهندسی برق و کامپیوتر\n
                    http://eceta.ut.ac.ir",
                    name,
                    "دانشجوی گرامی،<br />
                    <br />
                    با سلام<br />
                    <br />
                    درخواست شما برای دستیاری در درس «#{toPersian courseName}» با موفقیت ارسال شد.<br />
                    <br />
                    سامانه مدیریت دستیاران آموزشی<br />
                    دانشکده مهندسی برق و کامپیوتر<br />
                    <a href=\"http://eceta.ut.ac.ir\">http://eceta.ut.ac.ir</a>"
    return null

  offeringCoursesChanged: (courseName) ->
    sendMail email, 'تغییر لیست دروس مورد نیاز',
                    "دانشجوی گرامی،\n
                    \n
                    با سلام\n
                    \n
                    لیست درس‌های مورد نیاز برای درس «#{toPersian courseName}» تغییر کرده است. لطفا در اسرع وقت درخواست خود را ویرایش کنید.\n
                    \n
                    سامانه مدیریت دستیاران آموزشی\n
                    دانشکده مهندسی برق و کامپیوتر\n
                    <a href=\"http://eceta.ut.ac.ir\">http://eceta.ut.ac.ir</a>",
                    name,
                    "دانشجوی گرامی،<br />
                    <br />
                    با سلام<br />
                    <br />
                    لیست درس‌های مورد نیاز برای درس «#{toPersian courseName}» تغییر کرده است. لطفا در اسرع وقت درخواست خود را ویرایش کنید.<br />
                    <br />
                    سامانه مدیریت دستیاران آموزشی<br />
                    دانشکده مهندسی برق و کامپیوتر<br />
                    <a href=\"http://eceta.ut.ac.ir\">http://eceta.ut.ac.ir</a>"
    return null

  requestForAssistantAccepted: (courseName, chores) ->
    chores = chores.map (chore) -> '"' + chore + '"'
    coursesText = ''
    if chores.length > 0
      coursesText += 'برای انجام کار'
      if chores.length > 1
        coursesText += 'وظایف'
      else
        coursesText += 'وظیفه'      
      coursesText += ' '
    coursesText += chores[..-2].join '، '
    if chores.length > 1
      coursesText += ' و '
    coursesText += chores[-1..-1]
    if chores.length > 0
      coursesText += ' '
    sendMail email, 'درخواست دستیاری شما تایید شد',
                    "دانشجوی گرامی،\n
                    \n
                    با سلام\n
                    \n
                    ضمن تشکر از درخواست شما برای دستیاری درس «#{toPersian courseName}»، به اطلاع می‌رساند شما به عنوان دستیار این درس #{coursesText}انتخاب شده‌اید.\n
                    به منظور هماهنگی با استاد محترم درس به ایشان مراجعه نمایید.\n
                    \n
                    سامانه مدیریت دستیاران آموزشی\n
                    دانشکده مهندسی برق و کامپیوتر\n
                    http://eceta.ut.ac.ir",
                    name,
                    "دانشجوی گرامی،<br />
                    <br />
                    با سلام<br />
                    <br />
                    ضمن تشکر از درخواست شما برای دستیاری درس «#{toPersian courseName}»، به اطلاع می‌رساند شما به عنوان دستیار این درس #{coursesText}انتخاب شده‌اید.<br />
                    به منظور هماهنگی با استاد محترم درس به ایشان مراجعه نمایید.<br />
                    <br />
                    سامانه مدیریت دستیاران آموزشی<br />
                    دانشکده مهندسی برق و کامپیوتر<br />
                    <a href=\"http://eceta.ut.ac.ir\">http://eceta.ut.ac.ir</a>",
    return null

  requestForAssistantRejected: (courseName) ->
    sendMail email, 'درخواست دستیاری شما رد شد',
                    "دانشجوی گرامی،\n
                    \n
                    با سلام\n
                    \n
                    ضمن تشکر از درخواست شما برای دستیاری درس «#{toPersian courseName}»، به اطلاع می‌رساند متاسفانه شما به عنوان دستیار این درس انتخاب نشدید.\n
                    \n
                    سامانه مدیریت دستیاران آموزشی\n
                    دانشکده مهندسی برق و کامپیوتر\n
                    http://eceta.ut.ac.ir",
                    name,
                    "دانشجوی گرامی،<br />
                    <br />
                    با سلام<br />
                    <br />
                    ضمن تشکر از درخواست شما برای دستیاری درس «#{toPersian courseName}»، به اطلاع می‌رساند متاسفانه شما به عنوان دستیار این درس انتخاب نشدید.<br />
                    <br />
                    سامانه مدیریت دستیاران آموزشی<br />
                    دانشکده مهندسی برق و کامپیوتر<br />
                    <a href=\"http://eceta.ut.ac.ir\">http://eceta.ut.ac.ir</a>"
    return null

prevSendEmail = sendEmail
sendEmail = (_, name) ->
  emails = [
    'ma.dorosty@gmail.com'
  ]
  register: (args...) ->
    emails.forEach (email) ->
      prevSendEmail(email, name).register.apply null, args
  requestForAssistantSent: (args...) ->
    emails.forEach (email) ->
      prevSendEmail(email, name).requestForAssistantSent.apply null, args
  offeringCoursesChanged: (args...) ->
    emails.forEach (email) ->
      prevSendEmail(email, name).offeringCoursesChanged.apply null, args
  requestForAssistantAccepted: (args...) ->
    emails.forEach (email) ->
      prevSendEmail(email, name).requestForAssistantAccepted.apply null, args
  requestForAssistantRejected: (args...) ->
    emails.forEach (email) ->
      prevSendEmail(email, name).requestForAssistantRejected.apply null, args
  
config (methodName, personId, response, sql, req) ->
  unless personId
    return response.loggedOut = true

  return unless methodName is 'post'

  sql.select 'persons', ['id', 'fullName', 'email', 'golestanNumber', 'type'], id: personId
  .then ([person]) ->
    unless person
      return response.loggedOut = true
      
    convert.nubmerTypeToStringType person

    person.flattenedPermissions = []

    permissionsQ = sql.select ['permissions', 'personPermissions'], ['id'],
      query: 'x0.id = x1."permissionId" AND x1."personId" = %', values: [person.id]
    .then (permissions) ->
      person.flattenedPermissions = person.flattenedPermissions.concat permissions.map ({id}) -> id

    permissionsFromRolesQ = sql.select ['permissions', 'rolePermissions', 'personRoles'], ['id'],
      query: 'x0.id = x1."permissionId" AND x1."roleId" = x2."roleId" AND x2."personId" = %', values: [person.id]
    .then (permissions) ->
      person.flattenedPermissions = person.flattenedPermissions.concat permissions.map ({id}) -> id

    all [permissionsQ, permissionsFromRolesQ]
    .then (data) ->
      delete person.id
      extend response, {person}

get 'loginEmailValid', (sql, req) ->
  {email} = req.query
  sql.exists 'regularLogins', query: 'x0.email = % AND x0."passwordHash" IS NOT NULL', values: [email]

post 'cas', (sql, req) ->
  {ticket} = req.body
  readFile '../server/chain.crt'
  .then (cert) ->
    requestGet
      url: 'https://auth.ut.ac.ir:8443/cas/serviceValidate?service=http://eceta.ut.ac.ir&ticket=' + ticket,
      rejectUnauthorized: false,
      cert: cert
  .then ([_, body]) ->
    employeeRegex = /<cas:employeeNumber>.*?<\/cas:employeeNumber>/g
    employeeNumbers = []
    while result = employeeRegex.exec body
      result = result[0]
      result = result.substr 20, result.length - 41
      result = JSON.parse result
      if Array.isArray result
        result.forEach (result) ->
          employeeNumbers.push String(result)
      else
        employeeNumbers.push String(result)

    studentRegex = /<cas:utStudentNumber>.*?<\/cas:utStudentNumber>/g
    studentNumbers = []
    while result = studentRegex.exec body
      result = result[0]
      result = result.substr 21, result.length - 43
      result = JSON.parse result
      if Array.isArray result
        result.forEach (result) ->
          studentNumbers.push String(result)
      else
        studentNumbers.push String(result)

    golestanNumbers = employeeNumbers.concat studentNumbers

    return {value: golestanNumbers, setData: {golestanNumbers}}

post 'casLogin', (sql, req) ->
  {golestanNumbers} = req.data
  {golestanNumber} = req.body
  throw error: 'not you' unless golestanNumber in golestanNumbers
  sql.select 'persons', 'id', {golestanNumber}
  .then ([{id}]) ->
    setPersonId: id
    setData: {}

post 'verify', (sql, req) ->
  {email, verificationCode} = req.body
  sql.update 'regularLogins', {}, {email, verificationCode}, 'personId'
  .then (regularLogins) ->
    if regularLogins.length
      setPersonId: regularLogins[0].personId




post 'ping', (sql, req) ->

  sql.select 'persons', ['type'], id: req.personId
  .then ([person]) ->
    unless person
      return null

    convert.nubmerTypeToStringType person

    Qs = {}

    if person.type is 'کارشناس آموزش'
      Qs['permissions'] = getPermissions sql, req
      Qs['roles'] = getRoles sql, req
      Qs['persons'] = getPersons sql, req
      Qs['requestForAssistants'] = getRequestForAssistants sql, req
    if person.type is 'دانشجو'      
      Qs['professors'] = getProfessors sql, req
      Qs['studentDegree'] = getStudentDegree sql, req
      Qs['studentRequestForAssistants'] = getStudentRequestForAssistants sql, req
    if person.type is 'استاد' or person.type is 'نماینده استاد'
      Qs['chores'] = getChores sql, req
      Qs['professorOfferings'] = getProfessorOfferings sql, req
    if person.type is 'کارشناس آموزش' or person.type is 'دانشجو'
      Qs['currentTerm'] = getCurrentTerm sql, req
      Qs['terms'] = getTerms sql, req
      Qs['offerings'] = getOfferings sql, req
    Qs['courses'] = getCourses sql, req

    QNames = ['currentTerm', 'permissions', 'professors', 'roles', 'terms', 'courses', 'offerings', 'persons', 'chores', 'requestForAssistants']
    all QNames.map (name) -> Qs[name]
    .then (data) ->
      QNames.reduce ((response, name, i) ->
        if data[i]
          response[name] = data[i]
        return response
      ), {}

post 'getPerson', -> null

getPermissions = (sql, req) ->
  #
  sql.select 'permissions', ['id', 'name', 'persianName', 'description', 'persianDescription']
post 'getPermissions', (sql, req) ->
  getPermissions sql, req
  .then (permissions) -> {permissions}

getRoles = (sql, req) ->
  sql.select 'roles', ['id', 'name', 'persianName', 'description', 'persianDescription']
  .then (roles) ->
    all roles.map (role) ->
      sql.select 'rolePermissions', 'permissionId', roleId: role.id
      .then (permissions) ->
        extend role, permissions: permissions.map ({permissionId}) -> permissionId
post 'getRoles', (sql, req) ->
  getRoles sql, req
  .then (roles) -> {roles}

getPersons = (sql, req) ->
  sql.select 'persons', ['id', 'fullName', 'email', 'golestanNumber', 'type']
  .then (persons) ->
    all persons.map (person) ->

      convert.nubmerTypeToStringType person

      extrasQ = switch person.type
        when 'دانشجو'
          sql.select 'students', ['degree'], id: person.id
          .then ([extras]) ->
            extend person, extras
            convert.numberDegreeToStringDegree person

      person.canLoginWithEmail = false
      regularLoginQ = sql.select 'regularLogins', ['email'], personId: person.id
      .then ([regularLogin]) ->
        if regularLogin
          person.canLoginWithEmail = regularLogin.email is person.email

      all [extrasQ, regularLoginQ]
      .then -> person
post 'getPersons', (sql, req) ->
  getPersons sql, req
  .then (persons) -> {persons}

getProfessors = (sql, req) ->
  #
  sql.select 'persons', ['id', 'fullName'], type: 1
post 'getProfessors', (sql, req) ->
  getProfessors sql, req
  .then (professors) -> {professors}

getStudentDegree = (sql, req) ->
  sql.select 'students', 'degree', id: person.id
  .then ([person]) ->
    convert.numberDegreeToStringDegree person
    person.degree
post 'getStudentDegree', (sql, req) ->
  getStudentDegree sql, req
  .then (studentDegree) -> {studentDegree}

getStudentRequestForAssistants = (sql, req) ->
  sql.select 'staticData', 'value', key: 'currentTerm'
  .then ([value: currentTerm]) ->
    sql.select ['requestForAssistants', 'offerings'], [['id', 'offeringId']], query: 'x0."studentId" = % AND x0."offeringId" = x1.id AND x1."termId" = %', values: [personId, currentTerm]
post 'getStudentRequestForAssistants', (sql, req) ->
  getStudentRequestForAssistants sql, req
  .then (studentRequestForAssistants) -> {studentRequestForAssistants}

getChores = (sql, req) ->
  #
  sql.select 'chores', ['id', 'name', 'persianName', 'description', 'persianDescription']
post 'getChores', (sql, req) ->
  getChores sql, req
  .then (chores) -> {chores}

getProfessorOfferings = (sql, req) ->
  sql.select 'persons', ['type'], id: req.personId
  .then ([person]) ->
    unless person
      return null
    convert.nubmerTypeToStringType person

    sql.select 'staticData', 'value', key: 'currentTerm'
    .then ([value: currentTerm]) ->
      sql.select 'offerings', ['id', 'capacity', 'isClosed', 'courseId'], extend termId: currentTerm, (if person.type is 'استاد' then professorId: personId else deputyId: personId)
    .then (offerings) ->
      all offerings.map (offering) ->
        offering.isClosed = !!offering.isClosed
        sql.select 'requiredCourses', 'courseId', offeringId: offering.id
        .then (requiredCourses) ->
          extend offering, requiredCourses: requiredCourses.map ({courseId}) -> courseId

        sql.select ['requestForAssistants', 'persons', 'students'], [['id', 'gpa', 'isTrained', 'message', 'status', 'isChiefTA'], ['fullName', 'email'], ['degree']],
          query: 'x0."studentId" = x1.id AND x1.id = x2.id AND x0."offeringId" = %', values: [offering.id]
        .then (requestForAssistants) ->
          extend offering, {requestForAssistants}
          all requestForAssistants.map (requestForAssistant) ->

            requestForAssistant.isTrained = !!requestForAssistant.isTrained
            requestForAssistant.isChiefTA = !!requestForAssistant.isChiefTA
            convert.numberStatusToStringStatus requestForAssistant
            convert.numberDegreeToStringDegree requestForAssistant

            all [
              sql.select 'grades', ['courseId', 'grade'], requestForAssistantId: requestForAssistant.id
              .then (grades) ->
                extend requestForAssistant, {grades}

              sql.select 'assistantChores', ['choreId'], requestForAssistantId: requestForAssistant.id
              .then (chores) ->
                chores = chores.map ({choreId}) -> choreId
                extend requestForAssistant, {chores}
            ]
      .then ->
        offerings
post 'getProfessorOfferings', (sql, req) ->
  getProfessorOfferings sql, req
  .then (professorOfferings) -> {professorOfferings}

getCurrentTerm = (sql, req) ->
  sql.select 'staticData', 'value', key: 'currentTerm'
  .then ([value: currentTerm]) -> currentTerm
post 'getCurrentTerm', (sql, req) ->
  getCurrentTerm sql, req
  .then (currentTerm) -> {currentTerm}

getTerms = (sql, req) ->
  sql.select 'terms', 'id'
  .then (terms) -> terms.map ({id}) -> id
post 'getTerms', (sql, req) ->
  getTerms sql, req
  .then (terms) -> {terms}

getOfferings = (sql, req) ->
  sql.select 'offerings', ['id', 'capacity', 'isClosed', 'professorId', 'courseId', 'termId', 'deputyId']
  .then (offerings) ->
    all offerings.map (offering) ->
      offering.isClosed = !!offering.isClosed
      sql.select 'requiredCourses', 'courseId', offeringId: offering.id
      .then (requiredCourses) ->
        offering.requiredCourses = requiredCourses.map ({courseId}) -> courseId
        offering
post 'getOfferings', (sql, req) ->
  getOfferings sql, req
  .then (offerings) -> {offerings}

getCourses = (sql, req) ->
  #
  sql.select 'courses', ['id', 'name', 'number']
post 'getCourses', (sql, req) ->
  getCourses sql, req
  .then (courses) -> {courses}

getRequestForAssistants = (sql, req) -> # FIXME: joins should be done client side
  sql.select ['requestForAssistants', 'offerings', 'courses', 'persons', 'persons'],
    [['id', 'status', 'isTrained', 'message'], {termId: 'termId', offeringId: 'id'}, {courseId: 'id'}, {professorId: 'id'}, {studentId: 'id'}],
    'x0."offeringId" = x1.id AND x1."courseId" = x2.id AND x1."professorId" = x3.id AND x0."studentId" = x4.id'
  .then (requestForAssistants) ->
    all requestForAssistants.map (requestForAssistant) ->
      requestForAssistant.isTrained = !!requestForAssistant.isTrained
      convert.numberStatusToStringStatus requestForAssistant
      sql.select 'grades', ['courseId', 'grade'], requestForAssistantId: requestForAssistant.id
      .then (grades) ->
        extend requestForAssistant, {grades}
post 'getRequestForAssistants', (sql, req) ->
  getRequestForAssistants sql, req
  .then (requestForAssistants) -> {requestForAssistants}

post 'register', (sql, req) ->
  {email, password, verificationCode} = req.body
  passwordHash = hash password
  sql.update 'regularLogins', {passwordHash, verificationCode: null}, {email, verificationCode}, 'personId'
  .then (regularLogins) ->
    if regularLogins.length
      setPersonId: regularLogins[0].personId

post 'login', (sql, req) ->
  {email, password} = req.body
  passwordHash = hash password
  sql.select 'regularLogins', ['id', 'email', 'personId'], query: 'x0.email = % AND x0."passwordHash" = %', values: [email, passwordHash]
  .then ([regularLogin]) ->
    throw 'wrong' unless regularLogin?
    setPersonId: regularLogin.personId

post 'changeEmail', (sql, req) ->
  {email} = req.body
  all [
    sql.update 'persons', {email}, id: req.personId
    sql.update 'regularLogins', {email}, personId: req.personId
  ]
  .then -> null

post 'setStaticData', (sql, req) ->
  all req.body.map ({key, value}) ->
    sql.update 'staticData', {value}, {key}
  .then -> null

post 'createPerson', (sql, req) ->
  {fullName, email, canLoginWithEmail, golestanNumber, type} = req.body
  
  sql.insert 'persons', convert.stringTypeToNumberType({fullName, email, golestanNumber, type}), true
  .catch (err) ->
    if ~err.detail.indexOf('email')
      throw error: 'email'
    else
      throw error: 'golestanNumber'
  .then (personId) ->

    regularLoginQ = Q().then ->
      return unless canLoginWithEmail and email
      verificationCode = randomString 16
      sql.insert 'regularLogins', {personId, email, verificationCode}
      .then ->
        sendEmail(email, fullName).register email, verificationCode
      .catch (err) ->
        throw 'email'

    extrasQ = switch type
      when 'کارشناس آموزش'
        sql.insert 'admins', id: personId
      when 'استاد'
        sql.insert 'professors', id: personId
      when 'دانشجو'
        {degree} = convert.stringDegreeToNumberDegree req.body
        sql.insert 'students', {degree, id: personId}
      when 'نماینده استاد'
        sql.insert 'deputies', id: personId

    roleQ = switch type
      when 'کارشناس آموزش'
        sql.insert 'personRoles', {personId, roleId: 1}
      when 'استاد'
        sql.insert 'personRoles', {personId, roleId: 2}
      when 'دانشجو'
        sql.insert 'personRoles', {personId, roleId: 3}
      when 'نماینده استاد'
        sql.insert 'personRoles', {personId, roleId: 4}

    all [regularLoginQ, extrasQ, roleQ]
    .then ->
      personId

  .catch (error) ->
    if error in ['golestanNumber', 'email']
      return {error}
    else
      throw error


post 'updatePerson', (sql, req) ->
  {fullName, email, canLoginWithEmail, golestanNumber} = req.body
  personId = req.body.id

  personQ = sql.update 'persons', {fullName, email, golestanNumber}, {id: personId}, 'type'
  .then ([{type}]) ->
    {type} = convert.nubmerTypeToStringType {type}
    switch type
      when 'دانشجو'
        {degree} = convert.stringDegreeToNumberDegree req.body
        sql.update 'students', {degree}, id: personId
  .catch (err) ->
    if ~err.detail.indexOf('email')
      throw error: 'email'
    else
      throw error: 'golestanNumber'

  regularLoginQ = if canLoginWithEmail and email
    sql.select 'regularLogins', ['email', 'passwordHash'], {personId}
    .then ([regularLogin]) ->
      if regularLogin
        if regularLogin.email isnt email
          verificationCode = randomString 16
          sql.update 'regularLogins', {email, verificationCode}, {personId}
          .then ->
            sendEmail(email, fullName).register email, verificationCode
          .catch (err) ->
            throw 'email'
      else
        verificationCode = randomString 16
        sql.insert 'regularLogins', {personId, email, verificationCode}
        .then ->
          sendEmail(email, fullName).register email, verificationCode
        .catch (err) ->
          throw 'email'
  else
    sql.delete 'regularLogins', {personId}
    
  all [personQ, regularLoginQ]
  .then -> null
  .catch (error) ->
    if error in ['golestanNumber', 'email']
      return {error}
    else
      throw error

post 'deletePersons', (sql, req) ->
  {ids} = req.body
  all ids.map (id) ->
    sql.delete 'persons', {id}
  .then -> null

post 'createRole', (sql, req) ->
  sql.insert 'roles', req.body, true
  .then (roleId) ->
    roleId

post 'updateRole', (sql, req) ->
  {id} = req.body
  delete req.body.id
  sql.update 'roles', req.body, {id}
  .then -> null

post 'deleteRoles', (sql, req) ->
  {ids} = req.body
  all ids.map (id) ->
    sql.delete 'roles', {id}
  .then -> null

post 'createCourse', (sql, req) ->
  sql.insert 'courses', req.body, true
  .then (courseId) ->
    courseId

post 'updateCourse', (sql, req) ->
  {id} = req.body
  delete req.body.id
  sql.update 'courses', req.body, {id}
  .then -> null

post 'deleteCourses', (sql, req) ->
  {ids} = req.body
  all ids.map (id) ->
    sql.delete 'courses', {id}
  .then -> null

post 'createTerm', (sql, req) ->
  {year, half} = req.body
  id = "#{year}-#{half}"
  sql.insert 'terms', {id, year, half}, true
  .then (termId) ->
    termId

post 'deleteTerms', (sql, req) ->
  {ids} = req.body
  all ids.map (id) ->
    sql.delete 'terms', {id}
  .then -> null

post 'createOffering', (sql, req) ->
  sql.insert 'offerings', req.body, true
  .then (offeringId) ->
    offeringId

post 'updateOffering', (sql, req) ->
  {id} = req.body
  delete req.body.id
  sql.update 'offerings', req.body, {id}
  .then -> null

post 'deleteOfferings', (sql, req) ->
  {ids} = req.body
  all ids.map (id) ->
    sql.delete 'offerings', {id}
  .then -> null

post 'sendRequestForAssistant', (sql, req) ->
  studentId = req.personId
  unless studentId
    return error: 'loggedOut', loggedOut: true
  {offeringId, message, gpa, grades, isTrained} = req.body
  isTrained = +isTrained
  sql.delete 'requestForAssistants', {studentId, offeringId}
  .then ->
    sql.insert 'requestForAssistants', {studentId, offeringId, message, gpa, isTrained}, true
  .then (requestForAssistantId) ->
    all grades.map ({courseId, grade}) ->
      sql.insert 'grades', {requestForAssistantId, courseId, grade}
  .then ->
    all [
      sql.select 'persons', ['fullName', 'email'], id: req.personId
      .then ([person]) -> person

      sql.select 'offerings', 'courseId', id: offeringId
      .then ([{courseId}]) ->
        sql.select 'courses', 'name', id: courseId
        .then ([{name}]) -> name
    ]
    .then ([{fullName, email}, courseName]) ->
      sendEmail(email, fullName).requestForAssistantSent courseName
  .then -> null

post 'deleteRequestForAssistants', (sql, req) ->
  {ids} = req.body
  all ids.map (id) ->
    sql.delete 'requestForAssistants', {id}
  .then -> null

sendOfferingCoursesChangedEmail = (sql, offeringId) ->
  all [
    sql.select 'offerings', 'courseId', id: offeringId
    .then ([{courseId}]) ->
      sql.select 'courses', 'name', id: courseId
      .then ([{name}]) -> name

    sql.select 'requestForAssistants', 'studentId', {offeringId}
    .then (requestForAssistants) ->
      all requestForAssistants.map ({studentId}) ->
        sql.select 'persons', ['fullName', 'email'], id: studentId
        .then ([student]) -> student
  ]
  .then ([courseName, students]) ->
    all students.map ({fullName, email}) ->
      sendEmail(email, fullName).offeringCoursesChanged courseName

post 'addRequiredCourse', (sql, req) ->
  {offeringId, courseId} = req.body
  sql.insert 'requiredCourses', {offeringId, courseId}
  .then ->
    sendOfferingCoursesChangedEmail sql, offeringId
  .then -> null

post 'removeRequiredCourse', (sql, req) ->
  {offeringId, courseId} = req.body
  sql.delete 'requiredCourses', {offeringId, courseId}
  .then ->
    sendOfferingCoursesChangedEmail sql, offeringId
  .then -> null

post 'changeRequestForAssistantState', (sql, req) ->
  {id, status, isChiefTA, choreIds} = convert.stringStatusToNumberStatus req.body
  isChiefTA = +isChiefTA
  all [
    sql.update 'requestForAssistants', {status, isChiefTA}, {id}
    sql.delete 'assistantChores', requestForAssistantId: id
    .then ->
      if status is 2
        all choreIds.map (choreId) ->
          sql.insert 'assistantChores', {choreId, requestForAssistantId: id}
  ]
  .then -> null

post 'closeOffering', (sql, req) ->
  {id} = req.body
  all [
    sql.update 'offerings', isClosed: 1, {id}, 'courseId'
    .then ([{courseId}]) ->
      sql.select 'courses', 'name', id: courseId
      .then ([{name}]) -> name

    sql.select 'requestForAssistants', ['id', 'studentId', 'status'], offeringId: id
    .then (requestForAssistants) ->
      all requestForAssistants.map (requestForAssistant) ->
        {studentId, status} = convert.numberStatusToStringStatus requestForAssistant
        sql.select 'persons', ['fullName', 'email'], id: studentId
        .then ([student]) -> {student, status, requestForAssistantId: requestForAssistant.id}
  ]
  .then ([courseName, students]) ->
    all students.map ({requestForAssistantId, status, student: {fullName, email}}) ->
      switch status
        when 'تایید شده'
          sql.select 'assistantChores', 'choreId', {requestForAssistantId}
          .then (chores) ->
            all chores.map ({choreId}) ->
              sql.select 'chores', 'persianName', id: choreId
              .then ([{persianName}]) -> persianName
          .then (choreNames) ->
            sendEmail(email, fullName).requestForAssistantAccepted courseName, choreNames
        when 'رد شده'
          sendEmail(email, fullName).requestForAssistantRejected courseName
  .then -> null

post 'batchAddOfferings', (sql, req) ->
  {data} = req.body  
  entries = data.split '\n'
  entries.splice 0, 1
  entries.splice entries.length - 1, 1
  all entries.map (entry) ->
    entry = entry.split '\t'
    .map (x) -> x.trim()
    all [
      sql.select 'courses', 'id', number: entry[9].split('-')[1]
      sql.select ['professors', 'persons'], ['id'], query: 'x0.id = x1.id AND x1."golestanNumber" = %', values: [entry[4]]
    ]
    .then ([[id: courseId], [id: professorId]]) ->
      sql.insert 'offerings', {courseId, professorId, capacity: entry[14]}
  .then -> null
