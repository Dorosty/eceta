component = require '../utils/component'
modal = require '../singletons/modal'
dropdown = require '../components/dropdown'
{generateId} = require '../utils/dom'
{toEnglish} = require '../utils'

module.exports = component 'chooseGolestanNumber', ({dom, events, service, returnObject}) ->
  {E, setStyle} = dom

  id = generateId()

  golestanNumber = E dropdown
  setStyle, golestanNumber.input, {id}

  contents = E class: 'form-group',
    E 'label', for: id, 'شماره دانشجویی / پرسنلی'
    golestanNumber

  returnObject
    display: (golestanNumbers) ->
      golestanNumber.update golestanNumbers
      golestanNumber.setSelectedId golestanNumbers[0]
      modal.instance.display
        autoHide: true
        Title: 'شماره دانشجویی / پرسنلی مورد نظر را انتخاب کنید'
        SubmitText: 'ورود'
        submit: ->
          service.casLogin golestanNumber: toEnglish golestanNumber.value()
