module.exports = Backbone.Model.extend
  url: "#{apiUrl}users/sign_in"
  remote: true
  initialize: ->
    self = @
    @on "change:project_id", (model,value) ->
      localforage.getItem('currentUser').then (vars) ->
        localforage.setItem 'currentUser', _.extend(vars, {project_id: parseInt(value)})

    @on "change:download change:download_total", (model,value) ->
      _.throttle( ->
        if CurrentUser.attributes.download == CurrentUser.attributes.download_total
          CurrentUser.set
            downoad_total: 0
            download: 0
      , 100 )
      
    
  signedIn: ->
    @get('auth_token')?

  fetchProjectData: ->
    return unless CurrentUser.get('project_id')?

    props = 
        data:
          project_id: CurrentUser.get 'project_id'

    UploadCollection.fetch props
    ChecklistCollection.fetch props
    ProjectDiaryCollection.fetch props
    HourCollection.fetch props
    ExposureHourCollection.fetch props

  fetchData: ->
    return unless CurrentUser.signedIn()

    UserCollection.fetch()
    ProjectCollection.fetch()
    ChecklistTemplateCollection.fetch()

    @fetchProjectData()

  project: ->
    ProjectCollection.get(@get('project_id'))

  signIn: (onSuccess, onError)->
    self = @
    @save(null, {success: (model, data, xhr) ->
      
      localforage.setItem "currentUser", {
        auth_token: model.get('auth_token')
        email: model.get('email')
        id: model.get('id')
        rememberme: model.get('rememberme')
      }

      self.fetchData()
      fabric.Answers.sendLogIn() if fabric?
      onSuccess(model, data, xhr) if onSuccess?
    , error: onError})
    @set 'online', true
    
  signOut: ->
    clearStorage()
    return unless @signedIn()
    console.log 'signout'
    fabric.Answers.sendCustomEvent('logout') if fabric?
    @clear()
    for url, collection of collections
      collection.reset null
      
    Router.navigate '/login', {trigger: true} 