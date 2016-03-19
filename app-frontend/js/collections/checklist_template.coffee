module.exports = require('./base.coffee').extend
  model: require('../models/base.coffee').extend
    urlRoot: "#{apiUrl}checklist_templates"
    to_s: ->
      @get('title')

