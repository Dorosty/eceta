exports.create = ({variables, components, dom}) ->
  {setStyle, append, empty, hide, show, enable, disable, addClass, removeClass} = dom  

  functions =
    submit: undefined
    close: undefined

    setEnabled: (enabled) ->
      variables.enabled = enabled
      if enabled
        enable components.submit
      else
        disable components.submit

    hide: ->
      functions.close?()
      $(components.modal.fn.element).modal 'hide'

    display: ({autoHide = false, submit, close, title, contents, submitText, closeText, submitType = 'primary', enabled = true}) ->

      variables.autoHide = autoHide

      setStyle components.title, text: title

      empty components.contents
      append components.contents, contents

      functions.setEnabled enabled

      setStyle components.submit, text: submitText
      if submitText
        show components.submit
      else
        hide components.submit

      setStyle components.close, text: closeText
      if closeText
        show components.close
      else
        hide components.close

      ['btn-primary', 'btn-danger'].forEach (klass) ->
        removeClass components.submit, klass

      addClass components.submit, "btn-#{submitType}"

      functions.submit = submit
      functions.close = close

      $(components.modal.fn.element).modal
        keyboard: false,
        backdrop: 'static'
