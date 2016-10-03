component = require '../../../utils/component'
modal = require '../../../singletons/modal'
stateSyncedDropdown = require '../../../components/dropdown/stateSynced'
numberInput = require '../../../components/restrictedInput/number'
{generateId} = require '../../../utils/dom'
{extend, toEnglish} = require '../../../utils'

module.exports = component 'offeringsCredit', ({dom, events, state, service, returnObject}) ->
  {E, setStyle, enable, disable} = dom
  {onEvent, onEnter} = events

  ids = [0..4].map generateId

  getId = ({id}) -> id

  course = E stateSyncedDropdown,
    stateName: 'courses'
    getId: getId
    getTitle: ({name}) -> name
  setStyle course.input, id: ids[0]

  professor = E stateSyncedDropdown,
    stateName: 'professors'
    getId: getId
    getTitle: ({fullName}) -> fullName
  setStyle professor.input, id: ids[1]

  term = E stateSyncedDropdown,
    stateName: 'terms'
    selectedIdStateName: 'currentTerm'
  setStyle term.input, id: ids[2]

  capacity = E numberInput, true
  setStyle capacity, id: ids[3], class: 'form-control'

  deputy = E stateSyncedDropdown,
    stateName: 'deputies'
    getId: getId
    getTitle: ({fullName}) -> fullName
  setStyle deputy.input, id: ids[4]
  deputy.showEmpty true

  contents = [
    E class: 'form-group',
      E 'label', for: ids[0], 'نام درس'
      course
    E class: 'form-group',
      E 'label', for: ids[1], 'نام استاد'
      professor
    E class: 'form-group',
      E 'label', for: ids[2], 'ترم'
      term
    E class: 'form-group',
      E 'label', for: ids[3], 'ظرفیت'
      capacity
    E class: 'form-group',
      E 'label', for: ids[4], 'نام نماینده استاد (اختیاری)'
      deputy
  ]

  allInputs = [course.input, professor.input, term.input, capacity, deputy.input]

  onEvent [course.input, professor.input, term.input], ['input', 'pInput'], ->
    modal.instance.setEnabled ~course.value() and ~professor.value() and ~term.value()

  onEnter allInputs, ->
    modal.instance.submit()
    
  onEvent capacity, ['focus', 'input'], ->
    capacity.dirty = true

  getServiceData = ->
    courseId: course.value().id
    professorId: professor.value().id
    termId: term.value()
    deputyId: if ~deputy.value() then deputy.value().id else null
    capacity: if capacity.value() then toEnglish capacity.value() else null

  offState = undefined

  returnObject
    credit: (isEdit) -> (offering) ->
      term.revalue()
      capacity.dirty = false
      if isEdit
        [course, professor].forEach (x) ->
          x.showEmpty false
        [course, professor, deputy].forEach (x) ->
          x.undirty()
        offState = state.offerings.on (offerings) ->
          offering = (offerings.filter ({id}) -> id is offering.id)[0]
          unless offering
            return modal.instance.hide()
          course.setSelectedId offering.courseId
          professor.setSelectedId offering.professorId
          deputy.setSelectedId offering.deputyId
        unless capacity.dirty
          setStyle capacity, value: offering.capacity
      else
        [course, professor].forEach (x) ->
          x.showEmpty true
        [course, professor, deputy].forEach (x) ->
          x.reset()
        setStyle capacity, value: ''

      modal.instance.display
        enabled: isEdit
        autoHide: true
        title: (if isEdit then 'جزئیات/ویرایش' else 'ایجاد') + ' فراخوان'
        submitText: if isEdit then 'ثبت تغییرات' else 'ایجاد'
        closeText: if isEdit then 'لغو تغییرات' else 'لغو'
        contents: contents
        close: ->
          offState?()
          offState = null
        submit: ->
          allInputs.forEach (x) -> disable x
          submitQ = if isEdit
              service.updateOffering extend id: offering.id, getServiceData()
            else
              service.createOffering getServiceData()
          submitQ
          .then ->
            allInputs.forEach (x) -> enable x
          .catch ->
            allInputs.forEach (x) -> enable x