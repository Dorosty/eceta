credit = require '.'
state = require '../../../state'
service = require '../../../service'
modal = require '../../../modal'
numberInput = require '../../../components/numberInput'
{extend} = require '../../../utils'
{E} = require '../../../utils/dom'

exports.createElement = ->

  componentState = {} # itemUpdateGetItem, itemUpdateCallback
  elements = {} # name, number
  offs = [] # {courses}

  elements.name = E 'input'
  elements.number = numberInput.createElement true

  offs.push state.courses.on (coruses) ->
    componentState.itemUpdateCallback? (coruses.filter ({id}) -> id is componentState.itemUpdateGetItem().id)[0]

  off: ->
    offs.forEach (x) -> x()
    offs = []
  show: credit
    entityName: 'درس'
    onClose: ->
      offs.forEach (x) -> x()
      offs = []
    fields: [
      {key: 'name', name: 'نام درس', element: elements.name}
      {key: 'number', name: 'شماره درس', element: elements.number.element}
    ]
    onItemUpdate: (getItem, callback) ->
      componentState.itemUpdateGetItem = getItem
      componentState.itemUpdateCallback = callback
      state.courses.on once: true, (courses) ->
        callback (courses.filter ({id}) -> id is getItem().id)[0]
    edit: ({id}) ->
      service.updateCourse
        id: id
        name: elements.name.value
        number: elements.number.element.value
    create: ->
      service.createCourse
        name: elements.name.value
        number: elements.number.element.value