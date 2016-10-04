component = require '../../utils/component'
modal = require '../../singletons/modal'
style = require './style'
Q = require '../../q'
{generateId} = require '../../utils/dom'
{extend} = require '../../utils'

module.exports = component 'bugReport', ({dom, events, state, service}) ->
  {E, setStyle} = dom
  {onEvent} = events

  bugReport = E style.bugReport, 'گزارش خطا'

  contents = E class: 'form-group',
    E 'label', for: id = generateId(), 'توضیحات خطای رخ داده (در صورت تمایل، به منظور ارتباط، نام و ایمیل خود را بنویسید.)'
    textbox = E 'textarea', extend {id}, style.bugReportTextbox

  onEvent textbox, 'input', ->
    modal.instance.setEnabled textbox.value()

  onEvent bugReport, 'click', ->
    setStyle textbox, value: ''
    modal.instance.display
      enabled: false
      autoHide: true
      title: 'گزارش خطا'
      submitText: 'ثبت'
      closeText: 'بستن'
      contents: contents
      submit: -> Q.Promise (resolve) ->
        disable textbox
        state.person.on once: true, allowNull: true, (person) ->
          resolve service.reportBug
            description: textbox.value()
            platform: JSON.stringify window.platform
            person: JSON.stringify person
          .then ->
            enable textbox
          .catch ->
            enable textbox

  bugReport