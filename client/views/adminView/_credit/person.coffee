credit = require '.'
state = require '../../../state'
service = require '../../../service'
numberInput = require '../../../components/numberInput'
gradeInput = require '../../../components/gradeInput'
dropdown = require '../../../components/dropdown'
{extend, toEnglish} = require '../../../utils'
{emailIsValid} = require '../../../utils/logic'
{E, bindEvent, show, hide, setStyle, append} = require '../../../utils/dom'

restyleCheckbox = (group, label, element) ->
  text = document.createTextNode label.innerText or label.innerHtml
  label.innerText = label.innerHtml = ''
  setStyle group, class: 'checkbox', marginBottom: 40
  setStyle element, class: ''
  append label, [element, text]

exports.createElement = ->

  componentState = {} # itemUpdateGetItem, itemUpdateCallback
  elements = {} # type, fullName, golestanNumber, email, canLoginWithEmail, degree
  offs = [] # {persons}, {typeChange}

  offs.push state.persons.on (persons) ->
    componentState.itemUpdateCallback? (persons.filter ({id}) -> id is componentState.itemUpdateGetItem().id)[0]

  elements.type = dropdown.createElement ((x) -> x), (x) -> x
  elements.fullName = E 'input'
  elements.golestanNumber = numberInput.createElement().element
  elements.email = E 'input', type: 'email'
  elements.canLoginWithEmail = E 'input', type: 'checkbox'
  elements.degree = dropdown.createElement ((x) -> x), (x) -> x
  elements.type.update ['کارشناس آموزش', 'استاد', 'دانشجو', 'نماینده استاد']
  elements.degree.update ['کارشناسی', 'کارشناسی ارشد', 'دکتری']
    
  showAppropriateFields = ->
    [elements.degree.element].forEach (element) ->
      if element.parentNode
        hide element.parentNode
    switch elements.type.element.value
      when 'دانشجو'
        [elements.degree.element].forEach (element) ->
          if element.parentNode
            show element.parentNode
  offs.push bindEvent elements.type.element, ['input', 'pInput'], showAppropriateFields

  off: ->
    offs.forEach (x) -> x()
    offs = []
  show: credit
    entityName: 'شخص'
    onClose: ->
      offs.forEach (x) -> x()
      offs = []
    fields: [
      {key: 'type', name: 'نوع', element: elements.type.element, dropdown: elements.type}
      {key: 'fullName', name: 'نام کامل', element: elements.fullName}
      {key: 'golestanNumber', name: 'شماره دانشجویی / پرسنلی', element: elements.golestanNumber}
      {
        key: 'email'
        name: 'ایمیل'
        element: elements.email
        setValue: (value, element) -> setStyle element, englishValue: value
      }
      {
        key: 'canLoginWithEmail'
        name: 'امکان ورود با ایمیل'
        element: elements.canLoginWithEmail
        restyle: restyleCheckbox
        setValue: (value, element) -> setStyle element, checked: value
      }
      {key: 'degree', name: 'مقطع', element: elements.degree.element, dropdown: elements.degree}
    ]
    viewDidLoad: (isEdit) ->
      if isEdit
        hide elements.type.element.parentNode
      else
        show elements.type.element.parentNode
      showAppropriateFields()
    onItemUpdate: (getItem, callback) ->
      componentState.itemUpdateGetItem = getItem
      componentState.itemUpdateCallback = callback
      state.persons.on once: true, (persons) ->
        callback (persons.filter ({id}) -> id is getItem().id)[0]
    isEnabled: ->
      elements.type.element.value and elements.fullName.value and elements.email.value and
      emailIsValid(elements.email.value) and switch elements.type.element.value
        when 'دانشجو'
          elements.degree.element.value
        else
          true
    edit: ({id, type}) ->
      person =
        id: id
        fullName: elements.fullName.value
        email: elements.email.value
        canLoginWithEmail: elements.canLoginWithEmail.checked
        golestanNumber: if elements.golestanNumber.value then toEnglish elements.golestanNumber.value else null
      switch type
        when 'دانشجو'
          extend person,
            degree: elements.degree.element.value or null
      service.updatePerson person
    create: ->
      person =
        type: elements.type.element.value
        fullName: elements.fullName.value
        email: elements.email.value or null
        canLoginWithEmail: elements.canLoginWithEmail.checked
        golestanNumber: if elements.golestanNumber.value then toEnglish elements.golestanNumber.value else null
      switch person.type
        when 'دانشجو'
          extend person,
            degree: elements.degree.element.value or null
      service.createPerson person
