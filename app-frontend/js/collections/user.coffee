module.exports = require('./base.coffee').extend
  model: require('../models/base.coffee').extend
    urlRoot: "#{apiUrl}users"
    to_s: ->
      @get('first_name')
