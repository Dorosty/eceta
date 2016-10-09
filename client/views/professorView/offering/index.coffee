component = require '../../../utils/component'
Q = require '../../../q'
requiredCourses = require './requiredCourses'
cardView = require './cardView'
tableView = require './tableView'

module.exports = component 'professorOfferingView', ({dom, events, service, returnObject}) ->
  {E, show, hide, addClass, removeClass} = dom
  {onEvent} = events

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
    .fin -> isEditing = false

  view = E class: 'col-md-9', marginTop: 40,
    E marginBottom: 100,
      E 'h1', float: 'right', "درس #{offering.courseName}"
      unless offering.isClosed
        closeOffering = E 'button', class: 'btn btn-success', float: 'left', marginTop: 20, 'نهایی کردن انتخاب دستیاران...'
    E requiredCourses, offering
    E float: 'left',
      if requestForAssistants.length
        E class: 'btn btn-default', 'ارسال ایمیل به دستیاران' # TODO
        E class: 'btn-group',
          tableViewButton = E 'button', class: 'btn btn-default',
            E class: 'fa fa-table', cursor: 'pointer'
          cardViewButton = E 'button', class: 'btn btn-primary',
            E class: 'fa fa-bars', cursor: 'pointer'
    E 'h4', fontWeight: 'bold', marginBottom: 35, 'لیست درخواست‌های دانشجویان'
    if requestForAssistants.length
      hide tableViewInstance = requestsList, E tableView,
        {requestForAssistants: offering.requestForAssistants, changeRequestForAssistant}
      cardViewInstance = requestsList, E cardView,
        {requestForAssistants: offering.requestForAssistants, changeRequestForAssistant}
    else
      requestsList, E null, 'هنوز دانشجویی درخواست دستیاری در این درس نکرده است.'

  onEvent cardViewButton, 'click', ->
    isTableView = false
    removeClass cardViewButton 'btn-default'
    removeClass tableViewButton 'btn-primary'
    addClass cardViewButton, 'btn-primary'
    addClass tableViewButton, 'btn-default'
    hide tableViewInstance
    show cardViewInstance
    cardViewInstance.update()

  onEvent tableViewButton, 'click', ->
    removeClass cardViewButton 'btn-primary'
    removeClass tableViewButton 'btn-default'
    addClass cardViewButton, 'btn-default'
    addClass tableViewButton, 'btn-primary'
    show tableViewInstance
    hide cardViewInstance
    tableViewInstanceupdate()

  onEvent closeOffering, 'click', ->
    hasPending = requestForAssistants.filter(({status}) -> status is 'در حال بررسی').length
    accepted = requestForAssistants.filter(({status}) -> status is 'تایید شده').map ({fullName}) -> fullName
    modal.instance.display
      contents: if hasPending
          E 'h2', color: 'red', 'شما هنوز درخواست در حال بررسی دارید. لطفا ابتدا آنها را تایی یا رد کدید.'
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
        service.closeOffering id: offering.id

  returnObject
    isEditing = -> isEditing