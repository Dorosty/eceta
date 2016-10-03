# credit = require '../views/credit'
# service = require '../service'
# modal = require '../modal'
# dropdown = require '../components/dropdown'
# {toEnglish} = require '../utils'
# {E} = require '../utils/dom'

# golestanNumber = dropdown.createElement ((number) -> number), (number) -> number
# dialog = credit(
#   getTitle: -> 'شماره دانشجویی / پرسنلی مورد نظر را انتخاب کنید'
#   getSubmitText: -> 'ورود'
#   fields: [
#     {name: 'شماره دانشجویی / پرسنلی', element: golestanNumber.element, dropdown: golestanNumber}
#   ]
#   create: ->
#     service.casLogin golestanNumber: toEnglish golestanNumber.element.value
#     .fin ->
#       modal.hide()
#  )(false)

# exports.display = (golestanNumbers) ->
  # golestanNumber.update golestanNumbers, false
  # # golestanNumber.setSelectedId golestanNumbers[0]
  # dialog()
