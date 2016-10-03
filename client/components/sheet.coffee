component = require '../utils/component'
Q = require '../q'
modal = require '../singletons/modal'
{generateId} = require '../utils/dom'

module.exports = component 'sheet', ({dom, events, returnObject}) ->
  {E, setStyle, enable, disable} = dom
  {onEvent, onEnter} = events

  _getEnabled = false
  contens = E()

  returnObject

    # addField: ->
    # removeField: ->

    hide: -> modal.instance.hide()

    display: ({fields, viewDidLoad, getEnabled, submit, close, title, submitText='ثبت', closeText = 'بستن'}) ->

      _getEnabled = getEnabled

      empty contents
      append contents, fields.map ({name, component, restyle}) ->
        id = generateId()
        setStyle component, id: id, class: 'form-control'
        group = E class: 'form-group',
          label = E 'label', for: id, name
          component
        restyle? group, label, component
        group

      setEnabled = ->
        if _getEnabled
          enabled = _getEnabled()
        else
          enabled = fields.every ({optional, component}) -> optional or component.value()
        modal.instance.setEnabled enabled

      submit = do (submit) -> ->
        disable fields.map ({component}) -> component
        Q submit()
        .then ->
          enable fields.map ({component}) -> component
        .catch (e) ->
          enable fields.map ({component}) -> component
          throw e
          
      onEvent (fields.map ({component}) -> component), 'input', setEnabled
      onEnter (fields.filter((field) -> not field.noEnter).map ({element}) -> element), submit

      modal.instance.display {
        autoHide: true
        title
        contents
        submitText
        closeText
        submit
        close
      }

      setEnabled()

      viewDidLoad?()