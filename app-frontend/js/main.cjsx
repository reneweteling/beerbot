#####################################
# Libraries
# 
window.$                        = require 'jquery'
window._                        = require 'underscore'
window.Backbone                 = require 'backbone'
# window.React                    = require 'react'
window.ReactDOM                 = require 'react-dom'
window.backboneCollectionMixin  = require './mixins/backbone_collection_mixin.cjsx'
window.backboneModelMixin       = require './mixins/backbone_model_mixin.cjsx'

#####################################
# Requirering our elements
# 
window.App                            = require './pages/layout/app.cjsx'
window.Router                         = new (require './lib/router.coffee')
window.UserCollection                 = new (require './collections/user.coffee')
window.CurrentUser                    = new (require './models/session.coffee')

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