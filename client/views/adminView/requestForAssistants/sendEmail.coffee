component = require '../../../utils/component'
modal = require '../../../singletons/modal'
{generateId} = require '../../../utils/dom'

module.exports = component 'requestForAssistantsExtras', ({dom, events, service, returnObject}) ->
  {E, setStyle, show, hide, enable, disable} = dom
  {onEvent} = events

  contents = [
    E class: 'form-group',
      E 'label', for: id0 = generateId(), 'موضوع ایمیل'
      title = E 'input', id: id0, class: 'form-control'
    E class: 'form-group',
      E 'label', for: id1 = generateId(), 'متن ایمیل'
      message = E 'textarea',
        id: id1
        class: 'form-control'
        minHeight: 100
        minWidth: '100%'
        maxWidth: '100%'
  ]

  onEvent [title, message], 'input', ->
    modal.instance.setEnabled title.value() and message.value()

  returnObject
    show: (ids) ->
      setStyle title, value: ''
      setStyle message, value: ''
      modal.instance.display
        enabled: false
        autoHide: true
        title: 'ارسال ایمیل'
        submitText: 'ارسال'
        closeText: 'لغو'
        contents: contents
        submit: ->
          disable [title, message]
          service.sendEmail
            ids: ids
            title: title.value()
            message: message.value()
          .then ->
            enable [title, message]
          .catch ->
            enable [title, message]