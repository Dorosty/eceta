component = require '../../../utils/component'
modal = require '../../../singletons/modal'
numberInput = require '../../../components/restrictedInput/number'
{generateId} = require '../../../utils/dom'
{extend, toEnglish} = require '../../../utils'

module.exports = component 'requestForAssistantsCredit', ({dom, events, state, service, returnObject}) ->

  {E, text, setStyle} = dom
  {onEvent, onEnter} = events

  # onEvent [message], ['input', 'pInput'], ->
  #   modal.instance.setEnabled true

  # onEnter [], ->
  #   modal.instance.submit()

  returnObject
    credit: -> (requestForAssistant) ->

      state.all ['offerings', 'courses'], once: true, ([offerings, courses]) ->
        contents = [
          E class: 'form-group',
            E 'label', for: messageId = generateId(), 'پیام برای استاد'
            message = E 'textarea', value: requestForAssistant.message, id: messageId, class: 'form-control', minHeight: 100, minWidth: '100%', maxWidth: '100%'
        ]
        offering = (offerings.filter ({id}) -> String(id) is String(requestForAssistant.offeringId))[0]
        offering.requiredCourses
        .map (_id) -> (courses.filter ({id}) -> String(id) is String(_id))[0]
        .forEach (course) ->
          grade = (requestForAssistant.grades.filter ({courseId}) -> String(courseId) is String(course.id))[0]?.grade
          contents.push E class: 'form-group',
            E 'label', for: id = generateId(), "نمره درس #{course.name}"
            E 'input', id: id, class: 'form-control', value: grade
        contents.push E class: 'checkbox',
          E 'label', null,
            E 'input', type: 'checkbox', checked: requestForAssistant.isTrained
            text 'در کارگاه شرکت کرده است'


        modal.instance.display
          enabled: true
          autoHide: true
          title: 'جزئیات/ویرایش درخواست'
          submitText: 'ثبت تغییرات'
          closeText: 'لغو تغییرات'
          contents: contents
          submit: ->