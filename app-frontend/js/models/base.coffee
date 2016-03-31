module.exports = Backbone.Model.extend
  idAttribute: "id"
  parseBeforeLocalSave: (data) -> @parse(data)
  storeName: ->
    "#{@urlRoot.replace apiUrl, ''}"

  url: ->
    return "#{@urlRoot}/#{@get('id')}" if @get('id')?
    "#{@urlRoot}"

  to_s: ->
    @.get('name')

  uid: ->
    return @get('id') if @get('id')?
    @cid
    
  get: (key) -> 
    func = "get#{key.capitalizeFirst()}"
    return @[func]() if typeof @[func] == 'function'
    Backbone.Model.prototype.get.call(@, key)

  set: (key, value, options) ->
    if typeof key == 'string'
      func = "set#{key.capitalizeFirst()}"
      return @[func]() if typeof @[func] == 'function'
    
    Backbone.Model.prototype.set.call(@, key, value, options)

  setServerErrors: (errors) ->
    @validationError = errors

  validateCustom: (attr, options, addError) ->
    # for extending

  validate: (attr, options) ->
    errors = {}
    addError = (key, message) ->
      errors[key] ||= []
      errors[key].push message

    @validateCustom(attr, options, addError)

    if @validators?
    
      timeReg = /^(2[0-3]|1[0-9]|0[0-9]):([0-5][0-9])$/
      dateReg = /^(\d{4})-(1[0-2]|0[1-9])-(3[0-1]|[1-2]?[0-9]|0[1-9])$/
      datetimeReg = /^(\d{4})-(1[0-2]|0[1-9])-(3[0-1]|[1-2]?[0-9]|0[1-9])T(2[0-3]|1[0-9]|0[0-9]):([0-5][0-9]):([0-5][0-9])(\.000)?Z$/

      for key, validators of @validators
        value = attr[key]
        value ||= ''

        isPresent = value.toString().length > 0

        for validator in validators
          switch validator
            when 'required' then addError(key, "Dit veld is verplicht")           unless isPresent
            when 'numeric' then addError(key, "Dit veld is niet numeriek")        if isPresent and isNaN(value)
            when 'datetime' then addError(key, "Dit is geen valide datum tijd")   if isPresent and !value.match(datetimeReg)
            when 'time' then addError(key, "Dit is geen valide tijd")             if isPresent and !value.match(timeReg)
            when 'date' then addError(key, "Dit is geen valide datum")            if isPresent and !value.match(dateReg)
            else 
              console.warn "Validator: '#{validator}' unknown!!"

    if Object.keys(errors).length == 0
      false
    else
      console.warn ["Validation errors", errors, @]
      errors 
    