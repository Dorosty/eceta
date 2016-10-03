return

Q = require '../../q'

person =
  id: 1
  fullName: 'علی درستی'
  email: 'ma.dorosty@gmail.com'
  golestanNumber: 810190498
  type: 'کارشناس آموزش'

courses = [
  {id: 1, name: 'برنامه نویسی پیشرفته'}
  {id: 2, name: 'سیستم عامل'}
  {id: 3, name: 'ساختمان گسسته'}
]

persons = professors = [
  {id: 1, type: 'استاد', fullName: 'علی درستی'}
  {id: 2, type: 'استاد', fullName: 'دکتر خسروی'}
  {id: 3, type: 'استاد', fullName: 'مهندس رزاق'}
  {id: 4, type: 'دانشجو', fullName: 'اصغر'}
]

offerings = [
  {id: 1, courseId: 1, professorId: 1, termId: '1395-1', capacity: 10, isClosed: true}
  {id: 2, courseId: 2, professorId: 2, termId: '1395-1', capacity: 20, isClosed: false}
  {id: 3, courseId: 3, professorId: 3, termId: '1395-1', capacity: 30, isClosed: true}
]

requestForAssistants = [
  {id: 1, offeringId: 1, courseId: 1, professorId: 1, studentId: 4, termId: '1395-1', isTrained: true, status: 'تایید شده'}
  {id: 2, offeringId: 1, courseId: 1, professorId: 1, studentId: 4, termId: '1395-1', isTrained: false, status: 'تایید شده'}
  {id: 3, offeringId: 1, courseId: 1, professorId: 1, studentId: 4, termId: '1395-1', isTrained: true, status: 'رد شده'}
  {id: 4, offeringId: 2, courseId: 2, professorId: 2, studentId: 4, termId: '1395-1', isTrained: false, status: 'در حال بررسی'}
]

exports.ping = ->
  Q.delay 5000
  .then ->
    {person, persons, courses, offerings}

exports.getPerson = ->

exports.reportBug = ->
  Q.delay 100 + Math.floor Math.random() * 300

exports.loginEmailValid = ({email}) ->
  Q.delay 0# 100 + Math.floor Math.random() * 100
  .then ->
    email is 'ma.dorosty@gmail.com'

exports.login = ->
  Q.delay 0# 100 + Math.floor Math.random() * 300

exports.changeEmail = ->
  Q.delay 100 + Math.floor Math.random() * 300

exports.getTerms = ->
  Q.delay 100 + Math.floor Math.random() * 300
  .then ->
    terms: [].concat.apply [], [90..96].map (x) -> ["13#{x}-1", "13#{x}-2"]

currentTerm = '1395-1'
exports.getCurrentTerm = ->
  Q.delay 100 + Math.floor Math.random() * 300
  .then ->
    {currentTerm}
exports.setStaticData = ({value}) ->
  Q.delay 100 + Math.floor Math.random() * 300
  .then ->
    currentTerm = value
    value: {}


exports.getOfferings = ->
  Q.delay 100 + Math.floor Math.random() * 300
  .then ->
    {offerings}

exports.getCourses = ->
  Q.delay 100 + Math.floor Math.random() * 300
  .then ->
    {courses}

exports.getPersons = ->
  Q.delay 100 + Math.floor Math.random() * 300
  .then ->
    {persons}

exports.getRequestForAssistants = ->
  Q.delay 100 + Math.floor Math.random() * 300
  .then ->
    {requestForAssistants}

# exports.deleteOffering = ->
#   Q.delay 100 + Math.floor Math.random() * 300


Object.keys(exports).forEach (x) ->
  prev = exports[x]
  exports[x] = (args...) ->
    Q prev args...
    .then (response) ->
      if Array.isArray(response) or typeof response isnt 'object' or response is null
        response = value: response
      response.person = person
      response