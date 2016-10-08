component = require '../utils/component'
firstPage = require './firstPage'
adminView = require './adminView'
professorView = require './professorView'
studentView = require './studentView'

module.exports = component 'views', ({dom, state}) ->
  {E, append, empty} = dom

  wrapper = E margin: 30

  previousType = undefined  
  state.person.on allowNull: true, (person) ->

    type = person?.type ? null
    return if type is previousType
    previousType = type

    empty wrapper

    switch type
      when 'کارشناس آموزش'
        view = adminView
      when 'دانشجو'
        view = studentView
      when 'استاد', 'نماینده استاد'
        view = professorView
      else
        view = firstPage

    if view
      append wrapper, E view

  wrapper