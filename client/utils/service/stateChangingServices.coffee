{cruds} = require './names'
{uppercaseFirst} = require '..'

module.exports =
  logout:                          stateName: 'person'
  register:                        stateName: 'person'
  login:                           stateName: 'person'
  casLogin:                        stateName: 'person'
  verify:                          stateName: 'person'
  addRequiredCourse:               stateName: 'offerings' # CHECK: proferrorOfferings
  removeRequiredCourse:            stateName: 'offerings' # CHECK: proferrorOfferings
  sendRequestForAssistant:         stateName: 'studentRequestForAssistants'
  deleteRequestForAssistant:       stateName: 'studentRequestForAssistants'
  changeRequestForAssistantState:  stateName: 'professorOfferings'
  closeOffering:                   stateName: 'professorOfferings'
  batchAddOfferings:               stateName: 'offerings'

cruds.forEach ({name}) ->
  ['create', 'update'].forEach (method) ->
    module.exports["#{method}#{uppercaseFirst name}"] = stateName: "#{name}s"
  module.exports["delete#{uppercaseFirst name}s"] = stateName: "#{name}s"