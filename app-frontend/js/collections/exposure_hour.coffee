module.exports = require('./base.coffee').extend
  model: require('../models/base.coffee').extend
    urlRoot: "#{apiUrl}exposure_hours"
    validators:
      hour_id:        ['required', 'numeric'] 
      risk_category:  ['required', 'numeric']
      start_at:       ['required', 'datetime']
      end_at:         ['datetime']
    
    validateCustom: (attr, options, addError) ->
      
      hours = HourCollection.where({project_id: CurrentUser.get('project_id'), user_id: parseInt(attr.user_id) })

      start = Date.parse attr.start_at
      end = Date.parse attr.end_at

      @unset 'hour_id'

      # check if exposure hour is within previous hour
      fits = false
      for h in hours
        # console.log "Hour #{h.get('start_at')}-#{h.get('end_at')} | Exposure #{attr.start_at}-#{attr.end_at}"

        fits = true
        error = {}
        s = Date.parse(h.get('start_at'))

        if start <= s
          fits = false 
          addError('start', "Starttijd moet na #{dateFormat(h.get('start_at'),'time')} liggen")
        if h.get('end_at')? and end?
          if end >= Date.parse(h.get('end_at'))
            fits = false 
            addError('end',"Eindtijd moet voor #{dateFormat(h.get('end_at'),'time')} liggen")
        
        if fits    
          @set('hour_id', h.uid())
          break

      unless @get('hour_id')?
        addError('start',"Voor deze start en eind tijd is geen uur gevonden.")
        addError('end',"Voor deze start en eind tijd is geen uur gevonden.")

    hourModel: ->
      HourCollection.get(@get('hour_id')) || new (require '../models/base.coffee')()