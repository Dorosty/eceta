service = require './utils/service'
alert = require './singletons/alert'
{uppercaseFirst} = require './utils'

addMessage = service.extendModule (exports) ->
  addMessageLastRequestQ = undefined
  (name, {success, failure}) ->
    prev = exports[name]
    exports[name] = (args...) ->
      addMessageLastRequestQ = addMessageRequestQ = prev args...
      .then (x) ->
        if success
          if typeof success is 'function'
            alert.instance.show success(e), true
          else
            alert.instance.show success, true
          setTimeout (->
            if addMessageLastRequestQ is addMessageRequestQ
              alert.instance.hide()
          ), 3000
        return x
      .catch (e) ->
        if failure
          if typeof failure is 'function'
            alert.instance.show failure(e), false
          else
            alert.instance.show failure, false
          setTimeout (->
            if addMessageLastRequestQ is addMessageRequestQ
              alert.instance.hide()
          ), 3000
        throw e

exports.do = ->
  addMessage 'reportBug', success: 'گزارش خطا با موفقیت ارسال شد.'
  addMessage 'casLogin', success: 'خوش آمدید.', failure: 'شماره دانشجویی / پرسنلی انتخاب شده در سیستم موجود نمی‌باشد.'
  addMessage 'login', success: 'خوش آمدید.'
  addMessage 'register', success: 'رمز عبور با موفقیت ذخیره شد.'
  addMessage 'changeEmail', success: 'ایمیل با موفقیت ذخیره شد.', failure: 'ایمیل قبلا استفاده شده‌است.'
  addMessage 'setStaticData', success: 'تغییرات با موفقیت ذخیره شد.'
  addMessage 'sendRequestForAssistant', success: 'درخواست با موفقیت ارسال شد.'
  addMessage 'deleteRequestForAssistant', success: 'درخواست با موفقیت خذف شد.'
  addMessage 'addRequiredCourse', success: 'تغییرات با موفقیت ذخیره شد.'
  addMessage 'removeRequiredCourse', success: 'تغییرات با موفقیت ذخیره شد.'
  addMessage 'closeOffering', success: 'درس با موفقیت نهایی شد.'
  addMessage 'batchAddOfferings', success: 'عملیات با موفقیت انجام شد.', failure: 'در انجام عملیات مشکلی پیش آمد.'
  addMessage 'sendEmail', success: 'ایمیل با موفقیت ارسال شد.', failure: 'در انجام عملیات مشکلی پیش آمد.'
  [
    {name:'person', persianName: 'شخص'}
    {name:'course', persianName: 'درس'}
    {name:'offering', persianName: 'فراخوان'}
  ].forEach ({name, persianName}) ->
    addMessage "create#{uppercaseFirst(name)}", success: "#{persianName} با موفقیت ایجاد شد."
    addMessage "update#{uppercaseFirst(name)}", success: "تغییرات #{persianName} با موفقیت ذخیره شد."
    addMessage "delete#{uppercaseFirst(name)}s", success: "#{persianName} با موفقیت حذف شد."
  ['createPerson', 'updatePerson'].forEach (x) ->
    addMessage x, failure: (error) ->
      switch error
        when 'email'
          'ایمیل قبلا استفاده شده است.'
        when 'golestanNumber'
          'شماره دانشجویی / پرسنلی قبلا استفاده شده است.'