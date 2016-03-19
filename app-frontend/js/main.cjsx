if fabric?
  window.onerror = (message, source, lineno, colno, error) ->
    if CurrentUser? and CurrentUser.signedIn()
      fabric.Crashlytics.setUserIdentifier CurrentUser.get('id') 
      fabric.Crashlytics.setUserEmail CurrentUser.get('email')

    fabric.Crashlytics.addLog "#{message} | #{source} | #{lineno}:#{colno} | #{error}"
    fabric.Crashlytics.sendNonFatalCrash()

  oldlog = console.log.bind(console)
  window.console.log = (msg) -> 
    fabric.Crashlytics.addLog msg
    oldlog.call(console, msg)

  oldwarn = console.warn.bind(console)
  window.console.warn = (msg) -> 
    fabric.Crashlytics.addLog "warn - #{msg}"
    oldwarn.call(console, msg)

  olderror = console.error.bind(console)
  window.console.error = (msg) -> 
    fabric.Crashlytics.addLog "error - #{msg}"
    olderror.call(console, msg)
    fabric.Crashlytics.sendNonFatalCrash()

#####################################
# Libraries
# 
window.$                        = require 'jquery'
window._                        = require 'underscore'
window.Backbone                 = require 'backbone'
window.React                    = require 'react'
window.ReactList                = require 'react-list'
window.ReactDOM                 = require 'react-dom'
window.dateFormat               = require 'dateformat'
window.bs                       = require 'react-bootstrap'
window.localforage              = require 'localforage'
window.backboneCollectionMixin  = require './mixins/backbone_collection_mixin.cjsx'
window.backboneModelMixin       = require './mixins/backbone_model_mixin.cjsx'

#####################################
# Variables
# 
dateFormat.masks.time         = 'HH:MM'
dateFormat.masks.date         = 'yyyy-mm-dd'
dateFormat.masks.date_nl      = 'dd-mm-yyyy'
dateFormat.masks.datetime     = 'yyyy-mm-dd HH:MM' 
dateFormat.masks.datetime_nl  = 'dd-mm-yyyy HH:MM' 
window.is_iphone              = navigator.userAgent.toLowerCase().indexOf('iphone') > -1
window.online                 = true
window.env = 'prod'
window.env = 'dev' if apiUrl == 'https://secure.weteling.com/api/v1/'

#####################################
# Requirering our elements
# 

window.App                            = require './pages/layout/app.cjsx'
window.ExposureHourCollection         = new (require './collections/exposure_hour.coffee')
window.HourCollection                 = new (require './collections/hour.coffee')
window.ProjectCollection              = new (require './collections/project.coffee')
window.ProjectDiaryCollection         = new (require './collections/project_diary.coffee')
window.Router                         = new (require './lib/router.coffee')
window.UserCollection                 = new (require './collections/user.coffee')
window.ChecklistCollection            = new (require './collections/checklist.coffee')
window.ChecklistTemplateCollection    = new (require './collections/checklist_template.coffee')
window.UploadCollection               = new (require './collections/upload.coffee')

window.collections = 
  checklists: ChecklistCollection,
  checklist_templates: ChecklistTemplateCollection,
  exposure_hours: ExposureHourCollection
  hours: HourCollection,
  project_diaries: ProjectDiaryCollection,
  projects: ProjectCollection, 
  uploads: UploadCollection,
  users: UserCollection,

attachFastclick = require 'fastclick'
window.CurrentUser = new (require './models/session.coffee')

require './lib/functions.coffee'
require './lib/backbone.dualstorage.localforage.coffee'


#####################################
# Clearing local storage and files
# 
window.clearStorage ||= ->
  localforage.clear (err) ->
    if err?
      console.error err 
    else
      console.log "Database is now empty."

  return unless DirectoryEntry?
  
  dir = new DirectoryEntry('files', cordova.file.externalApplicationStorageDirectory)
  reader = dir.createReader()

  # reader.readEntries
  #   (entries) ->
  #     console.log entries

  #     for entry in entries
  #       entry.remove
  #         -> console.log "verwijderd"
  #         (error) -> console.error error

  #   (error) ->
  #     console.error error

  console.log "clearStorage doesnt exist!"

#####################################
# Dirty model syncing
# 

window.countAndSetDirty = ->
  return unless CurrentUser.signedIn()

  Promise.all( _.map(collections, (col) -> col.dirtyModels()) ).then (resp) ->
    models = []
    models.concat.apply(models, resp)
  .then (models) ->
    CurrentUser.set 'dirty_total', models.length
    for m in models
      m.save(null, {  success: -> CurrentUser.set 'dirty', CurrentUser.get('dirty') + 1 })
    
dirtyTimer = setInterval countAndSetDirty, 5000   

#####################################
# Ajax config
# 
$.ajaxSetup 
  beforeSend: (xhr) ->
    if CurrentUser? && CurrentUser.signedIn()
      xhr.setRequestHeader('X-User-Token', CurrentUser.get('auth_token'))
      xhr.setRequestHeader('X-User-Email', CurrentUser.get('email'))

$.support.cors = true
$.support.transition = false

# check for unauth statuscode, if so logout
$(document).ajaxError (event, jqxhr, settings, thrownError) -> 
  CurrentUser.signOut() if _.contains [401, 502], jqxhr.status
    
#####################################
## Boot!
#
window.boot = ->  
  setTimeout ->
    attachFastclick document.body
    ReactDOM.render( <App router={Router} />, document.getElementById('app') )
    Backbone.history.start 
      pushState: false
      
    # ensure loggedin
    Router.bind 'all', (routeevent,route) ->
      fabric.Answers.sendScreenView(route) if route? and fabric?
      unless CurrentUser.signedIn()
        @navigate '/login', {trigger: true}
      else unless CurrentUser.project()?
        @navigate '/projects', {trigger: true}

    # redirect to login
    Router.navigate '/login', {trigger: true} unless CurrentUser.signedIn()
    
    # hide splash
    navigator.splashscreen.hide() if navigator? and navigator.splashscreen?
  , 1500

$(document)
  .on 'online', -> CurrentUser.set('online', true)
  .on 'offline', -> CurrentUser.set('online', false)    
  .on 'deviceready', -> 
    localforage.getItem('currentUser')
      .then (vars) -> 
        if vars? and vars.rememberme == true
          CurrentUser.set _.extend( vars, { "online": true } )
          CurrentUser.fetchData()
        else
          CurrentUser.signOut()
        boot()
      .catch (err) -> 
        console.log err
        boot()