module.exports = Backbone.Model.extend
  url: "#{apiUrl}users/sign_in"
  remote: true
  # initialize: ->
  #   self = @
  signedIn: ->
    @get('auth_token')?

  defaults: ->
    json = localStorage.getItem 'currentUser'
    return JSON.parse json if json? and json.isJson()
    {}

  signIn: (onSuccess, onError)->
    self = @
    @save null, { success: (model, data, xhr) -> 
      localStorage.setItem "currentUser", JSON.stringify(model.attributes)
      Router.navigate '/index', {trigger: true} 
    }

  signOut: ->
    return unless @signedIn()
    @clear()
    localStorage.removeItem 'currentUser'
    Router.navigate '/login', {trigger: true} 