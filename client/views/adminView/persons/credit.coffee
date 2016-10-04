component = require '../../../utils/component'
modal = require '../../../singletons/modal'
dropdown = require '../../../components/dropdown'
numberInput = require '../../../components/restrictedInput/number'
{generateId} = require '../../../utils/dom'
{extend, toEnglish} = require '../../../utils'
{emailIsValid} = require '../../../utils/logic'

module.exports = component 'personsCredit', ({dom, events, state, service, returnObject}) ->
  {E, text, setStyle, show, hide, enable, disable} = dom
  {onEvent, onEnter} = events

  ids = [0..4].map -> generateId()

  type = E dropdown
  setStyle type.input, id: ids[0]
  type.showEmpty true
  type.update ['کارشناس آموزش', 'استاد', 'دانشجو', 'نماینده استاد']

  fullName = E 'input', id: ids[1], class: 'form-control'

  golestanNumber = E numberInput, true
  setStyle golestanNumber, id: ids[2], class: 'form-control'

  email = E 'input', id: ids[3], type: 'email', class: 'form-control'

  canLoginWithEmail = E 'input', type: 'checkbox'

  degree = E dropdown
  setStyle degree.input, id: ids[4]
  degree.update ['کارشناسی', 'کارشناسی ارشد', 'دکتری']

  contents = [
    typeGroup = E class: 'form-group',
      E 'label', for: ids[0], 'نوع'
      type
    E class: 'form-group',
      E 'label', for: ids[1], 'نام کامل'
      fullName
    E class: 'form-group',
      E 'label', for: ids[2], 'شماره دانشجویی / پرسنلی'
      golestanNumber
    E class: 'form-group',
      E 'label', for: ids[3], 'ایمیل'
      email
    E class: 'checkbox',
      E 'label', null,
        canLoginWithEmail
        text 'امکان ورود با ایمیل'
    buttonGroup = E class: 'form-group',
      button = E class: 'btn btn-default'
    degreeGroup = E class: 'form-group',
      E 'label', for: ids[4], 'مقطع'
      degree
  ]

  allInputs = [type.input, fullName, email, canLoginWithEmail, degree.input]

  onEvent allInputs, ['input, pInput', 'change'], ->
    modal.instance.setEnabled ~type.value() and fullName.value() and email.value() and
      emailIsValid(email.value()) and (type.value() isnt 'دانشجو' or ~degree.value())
  
  onEnter allInputs, ->
    modal.instance.submit()
    
  allInputs.forEach (input) ->
    onEvent input, ['focus', 'input', 'change'], ->
      input.dirty = true
  
  onEvent type, ['input', 'pInput'], ->
    if type.value() is 'دانشجو'
      show degreeGroup
    else
      show degreeGroup

  getServiceData = ->
    person =
      fullName: fullName.value()
      email: email.value()
      canLoginWithEmail: canLoginWithEmail.checked()
      golestanNumber: if golestanNumber.value() then toEnglish golestanNumber.value() else null
    switch type.value()
      when 'دانشجو'
        extend person,
          degree: if ~degree.value() then degree.value() else null
    person

  offState = offClick = undefined

  returnObject
    credit: (isEdit) -> (person) ->
      offClick?()
      allInputs.forEach (input) ->
        input.dirty = false
      if isEdit
        hide typeGroup
        type.setSelectedId person.type
        offState = state.persons.on (persons) ->
          person = (persons.filter ({id}) -> id is person.id)[0]
          unless person
            return modal.instance.hide()
          if person.canLoginWithEmail
            show buttonGroup
            if person.hasPassword
              setStyle button, text: 'ارسال مجدد ایمیل ثبت‌نام'
            offClick = onEvent button, 'click', ->
              disable button
              service.resetPassword personId: person.id
              .fin ->
                enable button
          else
            hide buttonGroup
          unless fullName.dirty
            setStyle fullName, value: person.fullName
          unless golestanNumber.dirty
            setStyle golestanNumber, value: person.golestanNumber
          unless email.dropdown
            setStyle email, englishValue: person.email
          unless canLoginWithEmail.dirty
            setStyle canLoginWithEmail, value: person.canLoginWithEmail
      else
        show typeGroup
        type.reset()
        hide buttonGroup
        setStyle fullName, value: ''
        setStyle golestanNumber, value: ''
        setStyle email, value: ''
        setStyle canLoginWithEmail, value: ''
      modal.instance.display
        enabled: isEdit
        autoHide: true
        title: (if isEdit then 'جزئیات/ویرایش' else 'ایجاد') + ' ضخص'
        submitText: if isEdit then 'ثبت تغییرات' else 'ایجاد'
        closeText: if isEdit then 'لغو تغییرات' else 'لغو'
        contents: contents
        close: ->
          offState?()
          offState = null
        submit: ->
          allInputs.forEach (x) -> disable x
          submitQ = if isEdit
            service.updatePerson extend id: person.id, getServiceData()
          else
            service.createPerson getServiceData()
          submitQ
          .then ->
            allInputs.forEach (x) -> enable x
          .catch ->
            allInputs.forEach (x) -> enable x