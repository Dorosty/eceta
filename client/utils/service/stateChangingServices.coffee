{cruds} = require './names'
{uppercaseFirst} = require '..'

module.exports =
  logout:                    stateName: 'person'
  register:                  stateName: 'person'
  login:                     stateName: 'person'
  casLogin:                  stateName: 'person'
  verify:                    stateName: 'person'
  sendRequestForAssistant:   stateName: 'requestForAssistants'
  deleteRequestForAssistant: stateName: 'requestForAssistants'
  addRequiredCourse:         stateName: 'offerings'
  removeRequiredCourse:      stateName: 'offerings'
  changeRequestForAssistant: stateName: 'offerings'
  closeOffering:             stateName: 'offerings'
  batchAddOfferings:         stateName: 'offerings'

cruds.forEach ({name}) ->
  ['create', 'update'].forEach (method) ->
    module.exports["#{method}#{uppercaseFirst name}"] = stateName: "#{name}s"
  module.exports["delete#{uppercaseFirst name}s"] = stateName: "#{name}s"