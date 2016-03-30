module.exports = require('./base.coffee').extend
  sort_key: 'beer_total'
  model: require('../models/base.coffee').extend
    urlRoot: "#{apiUrl}users"
    to_s: ->
      @get('first_name')
