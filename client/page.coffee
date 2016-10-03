component = require './utils/component'
navbar = require './navbar'
views = require './views'
alert = require './components/alert'
modal = require './components/modal'
singletonAlert = require './singletons/alert'
singletonModal = require './singletons/modal'
{body} = require './utils/dom'

module.exports = component 'page', ({dom}) ->
  {E, append} = dom
  
  append E(body), E navbar
  append E(body), E views
  append E(body), alertE = E alert
  append E(body), modalE = E modal

  singletonAlert.set alertE
  singletonModal.set modalE