component = require '../utils/component'
modal = require '../singletons/modal'
{generateId} = require '../utils/dom'
{passwordIsValid} = require '../utils/logic'

errorNames =
  password:
    empty: 'لطفا رمز عبور را وارد کنید'
    short: 'رمز عبور باید حد اقل ۶ حرف باشد'
  confirmPassword:
    notEqual: 'رمز عبور‌ها مطابقت ندارند'

module.exports = component 'register', ({dom, events, service, returnObject}) ->
  {E, addClass, removeClass, enable, disable} = dom
  {onEvent, onEnter} = events
  {register} = service

  returnObject
    display: ->

      alert = undefined

      fields = {}
      errors = password: errorNames.password.empty, confirmPassword: errorNames.confirmPassword.notEqual
      valid = false
      submitting = false

      do setEnabled = ->
        modal.instance.setEnabled valid = not errors.password and not errors.confirmPassword and not submitting

      updates = []
      submit = ->
        updates.forEach (update) -> update true
        return unless valid

        params = location.href.split '?'
        if params.length > 1 and params[1].indexOf('email=') is 0
          params = params[1].split '&'
          if params.length > 1 and (params[0].indexOf('email=') is 0) and (params[1].indexOf('verificationCode=') is 0)
            email = params[0].substr 'email='.length
            verificationCode = params[1].substr 'verificationCode='.length
          else
            return
        else
          return

        submitting = true
        setEnabled()
        {password, confirmPassword} = fields
        disable [password, confirmPassword]
        register {email, verificationCode, password: password.value}
        .then modal.instance.hide
        .catch ->
          addClass alert, 'in'
        .fin ->
          enable [password, confirmPassword]
          submitting = false
          setEnabled()
      modal.instance.display
        title: 'تغییر رمز عبور'
        submitText: 'ثبت'
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
                when 'password'
                  unless value
                    errors[fieldName] = errorNames.password.empty
                  else
                    if passwordIsValid value
                      delete errors[fieldName]
                    else
                      errors[fieldName] = errorNames.password.short
                    if fields.confirmPassword.value is value
                      delete errors.confirmPassword
                    else
                      errors.confirmPassword = errorNames.confirmPassword.notEqual
                when 'confirmPassword'
                  if fields.password.value is value
                    delete errors[fieldName]
                  else
                    errors[fieldName] = errorNames.confirmPassword.notEqual
              update()

            onEvent field, 'input', onAction true
            onEvent field, 'focusin', onAction true
            onEvent field, 'focusout', ->
              blurred = true
              update()
            onEnter field, submit

          passwordId = generateId()
          confirmPasswordId = generateId()
          view = [
            alert = E class: 'alert alert-danger fade',
              alertClose = E 'button', class: 'close', zIndex: 10, '×'
              E 'h4', null, 'رمز عبور اشتباه است'
            E class: 'form-group',
              E 'label', for: passwordId, 'رمز عبور'
              fields.password = E 'input', id: passwordId, class: 'form-control', type: 'password', direction: 'ltr'
            E class: 'form-group',
              E 'label', for: confirmPasswordId, 'تکرار رمز عبور'
              fields.confirmPassword = E 'input', id: confirmPasswordId, class: 'form-control', type: 'password', direction: 'ltr'
          ]
          bindFieldevents 'password'
          bindFieldevents 'confirmPassword'
          onEvent alertClose, 'click', ->
            removeClass alert, 'in'
          view