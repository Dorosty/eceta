component = require '../utils/component'
_login = require '../sheets/login'

module.exports = component 'firstPage', ({dom, events}) ->
  {E, empty} = dom
  {onEvent} = events

  login = E _login

  view = E width: (359 + 2 * 5) * 3, margin: '200px auto',
    email   = E 'img', cursor: 'pointer', margin: 5, src: 'assets/loginEmail.jpg'
    staff   = E 'img', cursor: 'pointer', margin: 5, src: 'assets/loginStaff.jpg'
    student = E 'img', cursor: 'pointer', margin: 5, src: 'assets/loginStudent.jpg'

  onEvent email, 'click', ->
    login.display()
  onEvent [staff, student], 'click', ->
    while document.body.children.length
      document.body.removeChild document.body.children[0]
    location.href = 'https://auth.ut.ac.ir:8443/cas/login?service=http%3A%2F%2Feceta.ut.ac.ir'

  view