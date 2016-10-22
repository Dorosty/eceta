{extend} = require '../../../../utils'

exports.course =
  borderRadius: 3
  display: 'inline-block'
  fontWeight: 'bold'
  marginLeft: 4
  padding: '2px 6px'
  height: 25
  lineHeight: 21
  color: '#31708f'
  backgroundColor: '#d9edf7'
  border: '1px solid #bce8f1'

exports.addCourse = extend {}, exports.course,
  color: '#3c763d'
  backgroundColor: '#dff0d8'
  borderColor: '#d6e9c6'
  cursor: 'pointer'

exports.courseAdorner =
  fontWeight: 'bold'
  cursor: 'pointer'
  cursor: 'pointer'

exports.courseX = extend {}, exports.courseAdorner,
  color: '#d43f3a'