exports.gets = [
  'loginEmailValid'
]

exports.posts = [
  'getPermissions'
  'getRoles'
  'getPersons'
  'getProfessors'
  'getStudentDegree'
  'getStudentRequestForAssistants'
  'getChores'
  'getProfessorOfferings'
  'getCurrentTerm'
  'getTerms'
  'getOfferings'
  'getCourses'
  'getRequestForAssistants'

  'reportBug'
  'cas'
  'login'
  'register'
  'changeEmail'

  'addRequiredCourse'
  'removeRequiredCourse'
  'sendRequestForAssistant'
  'changeRequestForAssistant'
  'deleteRequestForAssistant'
  'closeOffering'
  'batchAddOfferings'
]

exports.cruds = [  
  {name: 'person', persianName: 'شخص'}
  {name: 'course', persianName: 'درس'}
  {name: 'offering', persianName: 'گروه درسی'}
  {name: 'requestForAssistant', persianName: 'درخواست'}
]

exports.others = [
  'logout'
  'casLogin'
  'setStaticData'
]

exports.states = [
  'person'
  'roles'
  'permissions'
  'terms'
  'currentTerm'
  'offerings'
  'courses'
  'persons'
  'chores'
  'professors'
  'deputies'
  'requestForAssistants'

  'studentDegree'
  'studentRequestForAssistants'

  'professorOfferings'
]