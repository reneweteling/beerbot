module.exports = require('./base.coffee').extend
  model: require('../models/base.coffee').extend
    urlRoot: "#{apiUrl}checklists"
    to_s: ->
      @get('title')
    userModel: ->
      UserCollection.get(@get('user_id')) || new (require '../models/base.coffee')()

