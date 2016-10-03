crudPage = require './crudPage'
creditPerson = require './credit/person'
state = require '../../state'
service = require '../../service'
numberInput = require '../../components/numberInput'
{toPersian} = require '../../utils'
{E} = require '../../utils/dom'

exports.createElement = ->

  service.getPersons()

  componentState = {} # dataGetterCallback
  elements = {} # element, credit, page
  offs = [] # {persons}, {credit}

  elements.credit = creditPerson.createElement()
  offs.push elements.credit.off

  elements.page = crudPage.createElement
    entityName: 'شخص'
    headerNames: ['نوع', 'نام کامل', 'شماره دانشجویی / پرسنلی']
    itemKeys: ['type', 'fullName', 'golestanNumber']
    credit: elements.credit.show
    requiredStates: ['persons']
    deleteItem: (person) -> service.deletePerson person.id
    onDataGetter: (callback) -> componentState.dataGetterCallback = callback
    searchBoxes: [
      E 'select', class: 'form-control', marginTop: 20, fontWeight: 'normal',
        E 'option', value: '', ''
        ['کارشناس آموزش', 'استاد', 'دانشجو', 'نماینده استاد'].map (type) ->
          E 'option', value: type, type
      E 'input', class: 'form-control', marginTop: 20, fontWeight: 'normal', placeholder: 'جستجو...'
      numberInput.createElement(true, class: 'form-control', marginTop: 20, fontWeight: 'normal', placeholder: 'جستجو...').element
    ]

  elements.element = elements.page.element
  offs.push elements.page.off

  offs.push state.persons.on (persons) ->
    componentState.dataGetterCallback ([type, fullName, golestanNumber]) ->
      filteredPersons = persons
      if type
        filteredPersons = filteredPersons.filter (person) -> person.type is type
      if fullName
        filteredPersons = filteredPersons.filter (person) -> person.fullName and ~toPersian(person.fullName).toLowerCase().indexOf fullName
      if golestanNumber
        filteredPersons = filteredPersons.filter (person) -> person.golestanNumber and ~toPersian(person.golestanNumber).toLowerCase().indexOf golestanNumber
      return filteredPersons.sort (a, b) -> b.id - a.id

  element: elements.element
  off: ->
    offs.forEach (x) -> x()
    offs = []