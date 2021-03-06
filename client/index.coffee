Q = require './q'
service = require './utils/service'
page = require './page'
includes = require './includes'
alertMessages = require './alertMessages'
register = require './sheets/register'
chooseGolestanNumber = require './sheets/chooseGolestanNumber'

Q.longStackSupport = true

document.title = 'سامانه مدیریت دستیاران آموزشی'
params = location.href.split '?'

includes.do()
alertMessages.do()

_register = register()
_chooseGolestanNumber = chooseGolestanNumber()

service.autoPing()
service.getPerson()
.then ->
  page()

  if params.length > 1 
    if params[1].indexOf('ticket=') is 0
      ticket = params[1].substr 'ticket='.length
      service.cas ticket
      .then (golestanNumbers) ->
        if Array.isArray(golestanNumbers) and golestanNumbers.length
          $ -> setTimeout -> setTimeout -> setTimeout -> setTimeout -> setTimeout ->
            _chooseGolestanNumber.display golestanNumbers

    if params.length > 1 and params[1].indexOf('email=') is 0
      params = params[1].split '&'
      if params.length > 1 and (params[0].indexOf('email=') is 0) and (params[1].indexOf('verificationCode=') is 0)
        $ -> setTimeout -> setTimeout -> setTimeout -> setTimeout -> setTimeout ->
          _register.display()