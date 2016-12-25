Q = require '../../q'
component = require '../../utils/component'
table = require '../../components/table'
modal = require '../../singletons/modal'
numberInput = require '../../components/restrictedInput/number'
{toEnglish} = require '../../utils'

module.exports = component 'crudPage', ({dom, events, others, returnObject},
  {entityName, noCreating, headers, entityId, isEqual, onTableUpdate, deleteItems, credit, requiredStates, extraButtons = [], extraButtonsBefore = []}) ->
  {E, append, detatch, setStyle, empty} = dom
  {onEvent, onEnter} = events
  {loading} = others

  doCreate = credit false
  doEdit = credit true

  deleteButton = E class: 'btn btn-danger'
  deleteButtonVisible = false
  offDeleteClick = undefined

  view = E null,
    noData = E null, 'در حال بارگذاری...'
    yesData = [
      E class: 'row', margin: '10px 0',
        extraButtonsBefore
        group = E class: 'btn-group',
          unless noCreating
            create = E class: 'btn btn-primary', "ایجاد #{entityName}"
        extraButtons
        E marginTop: 30,
          tableInstance = E table, {
            headers
            entityId
            isEqual
            properties:
              multiSelect: true
            handlers:
              select: doEdit
              update: (entities) ->
                selectedEntities = entities.filter ({selected}) -> selected
                offClickDelete?()
                if selectedEntities.length
                  unless deleteButtonVisible
                    append group, deleteButton
                  deleteButtonVisible = true
                  setStyle deleteButton, text: "حذف #{selectedEntities.length} #{entityName} انتخاب شده"
                  offDeleteClick?()
                  offDeleteClick = onEvent deleteButton, 'click', ->
                    modal.instance.display
                      contents: E 'p', null," آیا از حذف این #{selectedEntities.length} #{entityName} اطمینان دارید؟"
                      submitText: 'حذف'
                      submitType: 'danger'
                      closeText: 'انصراف'
                      submit: ->
                        tableInstance.cover()
                        deleteItems selectedEntities.map ({entity}) -> entity
                        .fin -> tableInstance.uncover()
                        modal.instance.hide()
                else
                  if deleteButtonVisible
                    detatch deleteButton
                  deleteButtonVisible = false

                onTableUpdate? entities
          }
      pagination = E()
    ]

  unless noCreating
    onEvent create, 'click', doCreate

  loading requiredStates, yesData, noData

  returnObject
    setData: (items) ->
      pagesCount = Math.ceil items.length / 50
      empty pagination
      append pagination, [
        previousPage = E 'span', cursor: 'pointer', 'صفحه قبل'
        E 'span', null, '|'
        E 'span', null, 'صفحه '
        pageNumberInput = E numberInput, true
        E 'span', null, 'از ' + pagesCount
        E 'span', null, '|'
        nextPage = E 'span', cursor: 'pointer', 'صفحه بعد'
      ]
      currentPageNumber = 1
      gotoPage = (pageNumber) ->
        currentPageNumber = pageNumber = Math.max 1, Math.min pageNumber, pagesCount
        setStyle pageNumberInput, value: pageNumber
        tableInstance.setData items.slice (pageNumber - 1) * 50, Math.min items.length - 1, pageNumber * 50
      gotoPage 1
      onEvent previousPage, 'click', ->
        gotoPage currentPageNumber - 1
      onEvent nextPage, 'click', ->
        gotoPage currentPageNumber + 1
      onEnter pageNumberInput, ->
        gotoPage +toEnglish pageNumberInput.value()

    setSelectedRows: (callback) -> tableInstance.setSelectedRows callback

  view