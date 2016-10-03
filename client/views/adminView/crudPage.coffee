component = require '../../utils/component'
table = require '../../components/table'
modal = require '../../singletons/modal'
Q = require '../../q'

module.exports = component 'crudPage', ({dom, events, others, returnObject},
  {entityName, noCreating, headers, entityId, isEqual, onTableUpdate, deleteItems, credit, requiredStates, extraButtons = [], extraButtonsBefore = []}) ->
  {E, append, detatch, setStyle} = dom
  {onEvent} = events
  {loading} = others

  doCreate = credit false
  doEdit = credit true

  deleteButton = E class: 'btn btn-danger'
  deleteButtonVisible = false
  offDeleteClick = undefined

  element = E null,
    noData = E null, 'در حال بارگزاری...'
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
    ]

  unless noCreating
    onEvent create, 'click', doCreate

  loading requiredStates, yesData, noData

  returnObject
    setData: (items) -> tableInstance.setData items
    setSelectedRows: (callback) -> tableInstance.setSelectedRows callback

  element