{extend} = require '../../utils'

exports.font =
  fontWeight: 'normal'

exports.input =
  marginTop: 20
  class: 'form-control'
  placeholder: 'جستجو...'

exports.textbox = extend {}, exports.font, exports.input