exports.gets = [
  'loginEmailValid'
]

exports.posts = [
  'getPermissions'
  'getRoles'
  'getPersons'
  'getProfessors'
  'getChores'
  'getCurrentTerm'
  'getTerms'
  'getOfferings'
  'getCourses'
  'getRequestForAssistants'
  'getStudentRequestForAssistants'
  'getProfessorOfferings'
  'reportBug'
  'cas'
  'login'
  'register'
  'changeEmail'
  'sendEmail'
  'resetPassword'
  'changeRequestForAssistant' # side effects are handled in the page itself and not the service handler
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
  'sendRequestForAssistant'
  'addRequiredCourse'
  'removeRequiredCourse'
  'closeOffering'
  'batchAddOfferings'
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