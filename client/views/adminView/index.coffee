component = require '../../utils/component'
staticData = require './staticData'
# persons = require './persons'
# courses = require './courses'
offerings = require './offerings'
requestForAssistants = require './requestForAssistants'

tabNames = ['اطلاعات پایه', 'فراخوان‌ها', 'درخواست‌های دستیاری']# 'اشخاص', 'درس‌ها'
contentComponents = [staticData, offerings, requestForAssistants]# persons, courses
tabPermissions = {}

module.exports = component 'adminView', ({dom, events, state}) ->
  {E, addClass, removeClass, append, destroy, show, hide} = dom
  {onEvent} = events

  currentTabIndex = 0
  content = undefined
  offeringIds = null

  goToRequestForAssistants = (_offeringIds) ->
    offeringIds = _offeringIds
    changeTabIndex 2 ############################## 4

  changeTabIndex = (index) ->
    removeClass tabs[currentTabIndex], 'active'
    currentTabIndex = index
    addClass tabs[currentTabIndex], 'active'
    if content
      destroy content
    content = E contentComponents[currentTabIndex], {goToRequestForAssistants, offeringIds}
    append view, content

  view = E null,
    E 'ul', class: 'nav nav-tabs', marginBottom: 20,
      tabs = tabNames.map (tabName, index) ->
        tab = E 'li', null,
          E 'a', cursor: 'pointer', tabName
        onEvent tab, 'click', ->
          offeringIds = null
          changeTabIndex index
        tab
  changeTabIndex 0

  state.person.on (person) ->
    tabs.forEach (tab, index) ->
      permissions = tabPermissions[index]
      if not permissions or permissions in person.flattenedPermissions
        show tab
      else
        hide tab
        if currentTabIndex is index
          destroy content

  view