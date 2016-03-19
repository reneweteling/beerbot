Backbone.localforage            = require './lib/localforage-backbone.js'  

window.clearStorage = ->
  Backbone.localforage.localforageInstance.clear (err) ->
    if err?
      console.error err 
    else
      console.log "Database is now empty."

Backbone.ajaxSync = Backbone.sync

Backbone.sync = (method, model, options={}) ->
  error = options.error
  success = options.success
  type = 'model'
  type = 'collection' if model instanceof Backbone.Collection

  # Extend error method
  options.error = (resp, textStatus, errorThrown) ->
    error(resp) if error?
    # trigger errors, so if the model is on screen the errors will be visible.
    if resp.status == 422 and model instanceof Backbone.Model 
      model.setServerErrors resp.responseJSON
      model.trigger 'invalid' 

  # Extend succes method
  options.success = (resp) ->
    # method = options.reset ? 'reset' : 'set'
    success(resp) if success?
    if resp instanceof Array
      # result from local
      console.log "local"

    else if resp instanceof Object
      # Result from server
      console.log "server"

      if method == 'read'
        if type == 'model'
          console.log "Store #{model.storeName()} modal"
        if type == 'collection' and resp.models?
          console.log "Store models #{model.storeName()} locally"
          for m in resp.models
            mod = model.get(m.id)
            Backbone.sync.call(mod, 'update', mod, _.extend(options, {onlyLocal: true, success: null}))
    
  
  if model.storeName?

    # Localforage adapter
    sync = Backbone.localforage.sync(model.storeName())

    # This needs to be exposed for later usage, but it's private to
    # the adapter.
    @sync._localforageNamespace = sync._localforageNamespace

    # expose function used to create the localeForage key
    # this enable to have the key set before sync is called
    @sync._localeForageKeyFn = sync._localeForageKeyFn

    # Local sync
    unless options.onlyRemote == true or model.onlyRemote == true
      Prosync.call(@, method, model, options)

  # Ajax sync
  unless options.onlyLocal == true or model.onlyLocal == true
    Backbone.ajaxSync.call(@, method, model, options)
