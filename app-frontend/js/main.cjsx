#####################################
# Libraries
# 
window.$                        = require 'jquery'
window._                        = require 'underscore'
window.Backbone                 = require 'backbone'
window.React                    = require 'react'
window.ReactDOM                 = require 'react-dom'
window.backboneCollectionMixin  = require './mixins/backbone_collection_mixin.cjsx'
window.backboneModelMixin       = require './mixins/backbone_model_mixin.cjsx'
require './lib/functions.coffee'

#####################################
# Requirering our elements
# 
window.apiUrl                         = '/api/v1/'
window.App                            = require './pages/layout/app.cjsx'
window.Router                         = new (require './lib/router.cjsx')
window.UserCollection                 = new (require './collections/user.coffee')
window.BeerCollection                 = new (require './collections/beer.coffee')
window.CurrentUser                    = new (require './models/session.coffee')
window.AppModel                       = new Backbone.Model()
window.StatsData                      = []

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
$ ->
  require('fastclick')(document.body)

  ReactDOM.render( <App router={Router} model={AppModel} />, document.getElementById('app') )
  Backbone.history.start 
    pushState: false
    
  # ensure loggedin
  Router.bind 'all', (routeevent,route) ->
    unless CurrentUser.signedIn()
      @navigate '/login', {trigger: true}
    
  # redirect to login
  Router.navigate '/login', {trigger: true} unless CurrentUser.signedIn()