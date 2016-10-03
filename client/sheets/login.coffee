component = require '../utils/component'
modal = require '../singletons/modal'
{generateId} = require '../utils/dom'
{emailIsValid, passwordIsValid} = require '../utils/logic'

errorNames =
  email:
    empty: 'لطفا ایمیل را وارد کنید'
    invalid: 'ایمیل نامعتبر است'
    notExists: 'کاربری با این ایمیل وجود ندارد'
  password:
    empty: 'لطفا رمز عبور را وارد کنید'
    short: 'رمز عبور باید حد اقل ۶ حرف باشد'

module.exports = component 'login', ({dom, events, service, returnObject}) ->
  {E, addClass, removeClass, show, hide, enable, disable} = dom
  {onEvent, onEnter} = events
  {loginEmailValid, login} = service

  returnObject
    display: ->

      alert = undefined

      fields = {}
      errors = email: errorNames.email.empty, password: errorNames.password.empty
      valid = false
      submitting = false

      do setEnabled = ->
        modal.instance.setEnabled valid = not errors.email and not errors.password and not submitting

      updates = []
      submit = ->
        updates.forEach (update) -> update true
        return unless valid
        submitting = true
        setEnabled()
        {email, password} = fields
        disable [email, password]
        login email: email.value(), password: password.value()
        .then modal.instance.hide
        .catch ->
          addClass alert, 'in'
        .fin ->
          enable [email, password]
          submitting = false
          setEnabled()

      modal.instance.display
        title: 'ورود'
        submitText: 'ورود'
        submitType: 'primary'
        closeText: 'بستن'
        submit: submit
        contents: do ->

          bindFieldevents = (fieldName) ->
            field = fields[fieldName]

            blurred = false
            loading = false

            updates.push update = (force) ->
              JQElem = $ field.fn.element
              error = errors[fieldName]
              if error and (blurred or force) and not loading
                prevTooltip = JQElem.data 'bs.tooltip'
                if prevTooltip
                  prevTooltip.options.title = error
                else
                  JQElem.tooltip
                    trigger: 'manual'
                    placement: 'bottom'
                    title: error
                if JQElem.next('.tooltip').length is 0
                  JQElem.tooltip 'show'
              else
                JQElem.tooltip 'hide'

              setEnabled()

            checkQ = null
            onAction = (isChange) -> (e) ->
              element = e.target
              value = element.value
              blurred = document.activeElement isnt element
              switch fieldName
                when 'email'
                  unless value
                    errors[fieldName] = errorNames.email.empty
                  else unless emailIsValid value
                    errors[fieldName] = errorNames.email.invalid
                  else
                    if isChange
                      errors[fieldName] = errorNames.email.notExists
                      loading = true
                      show spinner
                      checkQ = xQ = loginEmailValid email: value
                      .then (isValid) ->
                        return unless checkQ is xQ
                        loading = false
                        hide spinner
                        if isValid
                          delete errors[fieldName]
                        update()
                      .done()
                when 'password'
                  unless value
                    errors[fieldName] = errorNames.password.empty
                  else if passwordIsValid value
                    delete errors[fieldName]
                  else
                    errors[fieldName] = errorNames.password.short
              update()

            onEvent field, 'input', onAction true
            onEvent field, 'focusin', onAction true
            onEvent field, 'focusout', ->
              blurred = true
              update()
            onEnter field, submit

          emailId = generateId()
          passwordId = generateId()
          view = [
            alert = E class: 'alert alert-danger fade',
              alertClose = E 'button', class: 'close', zIndex: 10, '×'
              E 'h4', null, 'رمز عبور اشتباه است.'
            E class: 'form-group', position: 'relative',
              E 'label', for: emailId, 'ایمیل'
              fields.email = E 'input', id: emailId, class: 'form-control', type: 'email', direction: 'ltr'
              spinner = E class: 'fa fa-circle-o-notch fa-spin fa-fw', position: 'absolute', right: 7, top: 35
            E class: 'form-group',
              E 'label', for: passwordId, 'رمز عبور'
              fields.password = E 'input', id: passwordId, class: 'form-control', type: 'password', direction: 'ltr'
          ]
          bindFieldevents 'email'
          bindFieldevents 'password'
          hide spinner
          onEvent alertClose, 'click', ->
            removeClass alert, 'in'
          view