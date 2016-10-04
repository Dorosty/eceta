component = require '../../../utils/component'
modal = require '../../../singletons/modal'
numberInput = require '../../../components/restrictedInput/number'
{generateId} = require '../../../utils/dom'
{extend, toEnglish} = require '../../../utils'

module.exports = component 'coursesCredit', ({dom, events, state, service, returnObject}) ->
  {E, setStyle, enable, disable} = dom
  {onEvent, onEnter} = events

  ids = [0..1].map generateId

  name = E 'input', id: ids[0], class: 'form-control'

  number = E numberInput, true
  setStyle number, id: ids[1], class: 'form-control'

  contents = [
    E class: 'form-group',
      E 'label', for: ids[0], 'نام درس'
      name
    E class: 'form-group',
      E 'label', for: ids[1], 'شماره درس'
      number
  ]

  allInputs = [name, number]

  onEvent allInputs, ->
    modal.instance.setEnabled ~name.value() and ~number.value()
  
  onEnter allInputs, ->
    modal.instance.submit()
    
  allInputs.forEach (input) ->
    onEvent input, ['focus', 'input'], ->
      input.dirty = true

  getServiceData = ->
    name: name.value()
    number: toEnglish number.value()

  offState = undefined

  returnObject
    credit: (isEdit) -> (course) ->
      allInputs.forEach (input) ->
        input.dirty = false
      if isEdit
        offState = state.courses.on (courses) ->
          course = (courses.filter ({id}) -> id is course.id)[0]
          unless course
            return modal.instance.hide()
          unless name.dirty
            setStyle name, value: course.name
          unless number.dirty
            setStyle number, value: course.number
      else
        setStyle name, value: ''
        setStyle number, value: ''

      modal.instance.display
        enabled: isEdit
        autoHide: true
        title: (if isEdit then 'جزئیات/ویرایش' else 'ایجاد') + ' درس'
        submitText: if isEdit then 'ثبت تغییرات' else 'ایجاد'
        closeText: if isEdit then 'لغو تغییرات' else 'لغو'
        contents: contents
        close: ->
          offState?()
          offState = null
        submit: ->
          allInputs.forEach (x) -> disable x
          submitQ = if isEdit
            service.updateCourse extend id: course.id, getServiceData()
          else
            service.createCourse getServiceData()
          submitQ
          .then ->
            allInputs.forEach (x) -> enable x
          .catch ->
            allInputs.forEach (x) -> enable x