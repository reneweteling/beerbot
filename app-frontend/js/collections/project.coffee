module.exports = require('./base.coffee').extend
  model: require('../models/base.coffee').extend
    urlRoot: "#{apiUrl}projects"
    to_s: ->
      @get('title')

