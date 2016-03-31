window.dutchDateToIsoDate = (dutchDate, dutchTime) ->
  # console.log [dutchDate, dutchTime]
  dutchDate = dutchDate.split '-'
  date = new Date(dutchDate[0], dutchDate[1]-1, dutchDate[2], 0, 0, 0, 0)
  if dutchTime?
    dutchTime = dutchTime.split ':'
    date.setHours dutchTime[0]
    date.setMinutes dutchTime[1]
  date.toISOString()

String::toFunctionName = ->
  @replace('_', '-').toCamel().capitalizeFirst()

String::capitalizeFirst = ->
  @charAt(0).toUpperCase() + @.slice(1)

String::capitalize = ->
  @replace /^./, (match) ->
    match.toUpperCase()

String::trim = ->
  @replace /^\s+|\s+$/g, ''

String::toCamel = ->
  @replace /(\-[a-z])/g, ($1) ->
    $1.toUpperCase().replace('-', '')

String::toDash = ->
  @replace /([A-Z])/g, ($1) ->
    '-' + $1.toLowerCase()

String::toUnderscore = ->
  @replace /([A-Z])/g, ($1) ->
    '_' + $1.toLowerCase()

String::isJson = ->
  try
    JSON.parse @
    true
  catch
    false

window.addEventListener 'load', (e) ->
  window.applicationCache.addEventListener 'updateready', (e) ->
    console.log window.applicationCache.status
    if window.applicationCache.status == window.applicationCache.UPDATEREADY
      if confirm('Update beschikbaar, laden?')
        window.location.reload()

window.hideModal = ->
  CurrentUser.set('modal', _.extend( CurrentUser.get('modal'), {open: false} ) )
  CurrentUser.trigger 'change'

  setTimeout ->
    CurrentUser.set
      modal:
        open: false
  , 500

window.showModal = (title, body, buttons={}) ->
  CurrentUser.set
    modal:
      open: true
      title: title
      body: body
      buttons: buttons

window.openFile = (uploadModel) ->
  cordova.plugins.FileOpener.openFile(uploadModel.get('path')) if cordova? and cordova.plugins? and cordova.plugins.FileOpener?