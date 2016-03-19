module.exports = Backbone.Router.extend
  routes:
    ''                                      : 'root'
    'projects'                              : 'projectIndex'
    'diary'                                 : 'diaryIndex'
    'hours'                                 : 'hourIndex' 
    'hours/new'                             : 'hourEdit' 
    'hours/:hour/edit'                      : 'hourEdit' 
    'hours/:hour/sign'                      : 'hourSign' 
    'exposure(/user-:user)'                 : 'exposureIndex'
    'exposure/user-:user/new'               : 'exposureNew' 
    'exposure/:exposure/edit'               : 'exposureEdit' 
    'checklist(/:tab)'                      : 'checklistIndex' 
    'checklist/:tab/:list/edit'             : 'checklistEdit' 
    'checklist/:tab/new'                    : 'checklistEdit' 
    'files'                                 : 'filesIndex'
    'login'                                 : 'login'
    'logout'                                : 'login'
    '*path'                                 : 'notFound'
  root: ->
    id = CurrentUser.get('project_id')
    if id?
      Router.navigate '/diary', {trigger:true}
    else
      Router.navigate '/projects', {trigger:true}

  projectIndex: ->
    @current = 'projectIndex'
    @collection = ProjectCollection
  diaryIndex: ->
    @current = 'diaryIndex'
    @collection = ProjectDiaryCollection
  filesIndex: ->
    @current = 'filesIndex'
    @collection = UploadCollection
  hourIndex: ->
    @current = 'hourIndex'
    @collection = HourCollection
  hourEdit: (hour = 'new') ->
    @current = 'hourEdit'
    if hour == 'new'
      @model = new HourCollection.model
      @model.collection = HourCollection
      @model.set('project_id', CurrentUser.get('project_id'))
    else 
      @model = HourCollection.get(hour)
  hourSign: (hour) ->
    @current = 'hourSign'
    @model = HourCollection.get(hour)
  exposureIndex: (user) ->
    @current = 'exposureIndex'
    @collection = ExposureHourCollection
    @user = UserCollection.get(user) if user

  exposureEdit: (exposure) ->
    @current = 'exposureEdit'
    @model = ExposureHourCollection.get(exposure)

  exposureNew: (user) ->
    @current = 'exposureEdit'
    @model = new ExposureHourCollection.model
    @model.collection = ExposureHourCollection
    @model.set('user_id', user)

  checklistIndex: (tab = 'daily') ->
    @current = 'checklistIndex'
    @tab = tab
    @collection = ChecklistCollection

  checklistEdit: (tab, list = 'new') ->
    @current = 'checklistEdit'
    @tab = tab

    if list != 'new'
      @model = ChecklistCollection.get(list)
    else
      @model = new ChecklistCollection.model
        templatetype: tab
        user_id: CurrentUser.get('id')

  login: -> 
    @current = 'login'
    CurrentUser.signOut() if CurrentUser.signedIn()
  
  notFound: -> 
    @current = 'error404'
