module.exports = require('./base.coffee').extend
  model: require('../models/base.coffee').extend
    validators:
      project_id: ['required', 'numeric']
      user_id:    ['required', 'numeric']
      start_at:   ['required', 'datetime']
      end_at:     ['datetime']
      
    urlRoot: "#{apiUrl}hours"
    projectModel: ->
      ProjectCollection.get(@get('project_id')) || new (require '../models/base.coffee')()
    userModel: ->
      UserCollection.get(@get('user_id')) || new (require '../models/base.coffee')()
    setServerErrors: (errors) ->
      @validationError = errors
      
      if @validationError.start_at
        @validationError.start = @validationError.start_at
      if @validationError.end_at
        @validationError.end = @validationError.end_at