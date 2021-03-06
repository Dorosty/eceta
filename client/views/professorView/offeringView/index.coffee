component = require '../../../utils/component'
sendEmail = require './sendEmail'
requiredCourses = require './requiredCourses'
cardView = require './cardView'
tableView = require './tableView'
modal = require '../../../singletons/modal'
Q = require '../../../q'

module.exports = component 'professorOfferingView', ({dom, events, state, service, returnObject}) ->
  {E, text, setStyle, show, hide, addClass, removeClass} = dom
  {onEvent} = events

  _sendEmail = E sendEmail

  offering = undefined
  update = (_offering) ->
    offering = _offering
    setStyle title, text: "درس #{offering.courseName}"
    requiredCoursesInstance.update offering
    tableViewInstance.update offering
    cardViewInstance.update offering
    if offering.isClosed
      hide closeOffering
    else
      show closeOffering
    if offering.requestForAssistants.length
      hide noRequestForAssistants
      show yesRequestForAssistants
    else
      show noRequestForAssistants
      hide yesRequestForAssistants

  isEditing = false
  lastRequest = Q()
  changeRequestForAssistant = (requestForAssistant) ->
    isEditing = true
    lastRequest = lastRequest.then ->
      isEditing = true
      service.changeRequestForAssistant
        id: requestForAssistant.id
        isChiefTA: requestForAssistant.isChiefTA
        choreIds: requestForAssistant.chores
        status: requestForAssistant.status
    .fin ->
      isEditing = false
      update offering

  view = E class: 'col-md-9', marginTop: 40,
    E marginBottom: 100,
      title = E 'h1', float: 'right'
      closeOffering = E 'button', class: 'btn btn-success', float: 'left', marginTop: 20, 'نهایی کردن انتخاب دستیاران...'
    requiredCoursesInstance = E requiredCourses
    noRequestForAssistants = E null, 'هنوز دانشجویی درخواست دستیاری در این درس نکرده است.'
    yesRequestForAssistants = [
      E float: 'left',
        E class: 'btn-group',
          tableViewButton = E 'button', class: 'btn btn-default',
            text 'نمایش جدولی'
            E class: 'fa fa-table', cursor: 'pointer', marginRight: 10
          cardViewButton = E 'button', class: 'btn btn-primary',
            text 'نمایش کارتی'
            E class: 'fa fa-bars', cursor: 'pointer', marginRight: 10
      E 'h4', fontWeight: 'bold', 'لیست درخواست‌های دانشجویان'
      sendEmailButton = E class: 'btn btn-default', marginBottom: 35, 'ارسال ایمیل به تمام دانشجویان متقاضی دستیاری'
      E 'span', null,
        hide tableViewInstance = E tableView, {changeRequestForAssistant}
        cardViewInstance = E cardView, {changeRequestForAssistant}
    ]

  onEvent cardViewButton, 'click', ->
    removeClass cardViewButton, 'btn-default'
    removeClass tableViewButton, 'btn-primary'
    addClass cardViewButton, 'btn-primary'
    addClass tableViewButton, 'btn-default'
    hide tableViewInstance
    show cardViewInstance

  onEvent tableViewButton, 'click', ->
    removeClass cardViewButton, 'btn-primary'
    removeClass tableViewButton, 'btn-default'
    addClass cardViewButton, 'btn-default'
    addClass tableViewButton, 'btn-primary'
    show tableViewInstance
    hide cardViewInstance

  onEvent sendEmailButton, 'click', ->
    _sendEmail.show offering.requestForAssistants.map ({studentId}) -> studentId

  onEvent closeOffering, 'click', ->
    hasPending = offering.requestForAssistants.filter(({status}) -> status is 'در حال بررسی').length
    accepted = offering.requestForAssistants.filter(({status}) -> status is 'تایید شده').map ({fullName}) -> fullName
    modal.instance.display
      contents: if hasPending
          E 'h4', fontWeight: 'bold', color: 'red', 'شما هنوز درخواست در حال بررسی دارید. لطفا ابتدا آنها را تایید یا رد کنید.'
        else
          [
            E 'h2', color: 'red', marginBottom: 30, 'آیا از نهایی کردن فهرست دستیاران اطمینان دارید؟'
            E fontWeight: 'bold', fontSize: 15,
              E marginBottom: 10, if accepted.length then "دستیاران انتخاب‌شده برای درس «#{offering.courseName}»:" else 'شما دانشجویی را به عونان دستیار تایید نکرده‌اید.'
              if accepted.length
                [
                  E 'ul', null, accepted.map (fullName) ->
                    E 'li', null, fullName
                  E marginTop: 20, 'در صورت نهایی کردن، رایانامه‌ای به این دانشجویان مبنی بر پذیرش آنها ارسال خواهد شد.'
                ]
          ]
      autoHide: true
      enabled: not hasPending
      submitText: if hasPending then null else 'نهایی کردن'
      closeText: if hasPending then 'بستن' else 'انصراف'
      submitType: 'danger'
      submit: ->
        service.closeOffering offering.id

  returnObject
    isEditing: -> isEditing
    update: update

  view