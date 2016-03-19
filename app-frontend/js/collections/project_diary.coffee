module.exports = require('./base.coffee').extend
  model: require('../models/base.coffee').extend
    urlRoot: "#{apiUrl}project_diaries"
    projectModel: ->
      projectCollection.get(@get('project_id')) || new (require '../models/base.coffee')()
    userModel: ->
      UserCollection.get(@get('user_id')) || new (require '../models/base.coffee')()