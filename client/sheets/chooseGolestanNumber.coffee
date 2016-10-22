component = require '../utils/component'
modal = require '../singletons/modal'
dropdown = require '../components/dropdown'
{generateId} = require '../utils/dom'
{toEnglish} = require '../utils'

module.exports = component 'chooseGolestanNumber', ({dom, events, service, returnObject}) ->
  {E, setStyle} = dom

  id = generateId()

  golestanNumber = E dropdown
  setStyle golestanNumber.input, {id}
  golestanNumber.showEmpty true

  contents = E class: 'form-group',
    E 'label', for: id, 'شماره دانشجویی / پرسنلی'
    golestanNumber

  returnObject
    display: (golestanNumbers) ->
      golestanNumber.update golestanNumbers
      modal.instance.display
        autoHide: true
        Title: 'شماره دانشجویی / پرسنلی مورد نظر را انتخاب کنید'
        submitText: 'ورود'
        contents: contents
        submit: ->
          service.casLogin toEnglish golestanNumber.value()
