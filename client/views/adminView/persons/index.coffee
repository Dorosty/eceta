component = require '../../../utils/component'
crudPage = require '../crudPage'
credit = require './credit'
multiselect = require './multiselect'
searchBoxStyle = require '../../../components/table/searchBoxStyle'
dropdown = require '../../../components/dropdown'
numberInput = require '../../../components/restrictedInput/number'
{textIsInSearch} = require '../../../utils'

module.exports = component 'personsView', ({dom, events, state, service}) ->
  {E, setStyle, append, empty} = dom
  {onEvent} = events

  service.getPersons()

  fullNameInput = E 'input', searchBoxStyle.textbox

  typeDropdown = E dropdown
  setStyle typeDropdown, searchBoxStyle.font    
  setStyle typeDropdown.input, searchBoxStyle.input
  typeDropdown.showEmpty true
  typeDropdown.update ['کارشناس آموزش', 'استاد', 'دانشجو', 'نماینده استاد']

  golestanNumberInput = E numberInput, true
  setStyle golestanNumberInput, searchBoxStyle.textbox

  view =  E crudPage,
    entityName: 'شخص'
    requiredStates: ['persons']
    extraButtonsBefore: multiselectInstance = E multiselect, (callback) -> view.setSelectedRows callback
    headers: [
      {name: 'نوع', key: 'type', searchBox: typeDropdown}
      {name: 'نام کامل', key: 'fullName', searchBox: fullNameInput}
      {name: 'شماره دانشجویی / پرسنلی', key: 'golestanNumber', searchBox: golestanNumberInput}
    ]
    onTableUpdate: (descriptors) ->
      multiselectInstance.setChecked descriptors
    credit: E(credit).credit
    deleteItems: (persons) -> service.deletePersons persons.map ({id}) -> id

  persons = []
  update = ->
    type = typeDropdown.value()
    fullName = fullNameInput.value()
    golestanNumber = golestanNumberInput.value()
    filteredPersons = persons
    if ~type
      filteredPersons = filteredPersons.filter (person) -> textIsInSearch person.type, type
    if fullName
      filteredPersons = filteredPersons.filter (person) -> textIsInSearch person.fullName, fullName
    if golestanNumber
      filteredPersons = filteredPersons.filter (person) -> textIsInSearch person.golestanNumber, golestanNumber
    view.setData filteredPersons

  state.persons.on (_persons) ->
    persons = _persons
    update()

  onEvent [typeDropdown.input, fullNameInput, golestanNumberInput], ['input', 'pInput'], update

  view