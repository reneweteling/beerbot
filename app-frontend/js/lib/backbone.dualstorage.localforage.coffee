###
Backbone dualStorage Adapter for localforage based on https://github.com/nilbus/Backbone.dualStorage v1.4.0

A simple module to replace `Backbone.sync` with *localForage*-based
persistence. Models are given GUIDS, and saved into a JSON object. Simple
as that.

Backbone.dualStorage:
  Author: Edward Anderson (nimbus)

Backbone.dualStorage.localforage:
  Author: René Weteling (reneweteling)

###

((root, factory) ->
  if typeof define == 'function' and define.amd
    define [
      'localforage'
      'backbone'
      'underscore'
    ], factory
  else if typeof module != 'undefined' and module.exports
    localforage = require('localforage')
    Backbone = require('backbone')
    _ = require('underscore')
    module.exports = factory(localforage, Backbone, _)
  else
    factory root.localforage, root.Backbone, root._
  return
) this, (localforage, Backbone, _) ->

  # A little proxy over our storage adapter so that we can easly change it if needed.
  storage = 
    set: (item, value) ->
      localforage.setItem(item, value)
        .catch (error) -> console.log error
    get: (item) ->
      localforage.getItem(item)
        .catch (error) -> console.log error
    remove: (item) ->
      localforage.removeItem(item)

  Backbone.DualStorage = {
    offlineStatusCodes: [408, 502]
  }

  Backbone.Model.prototype.hasTempId = ->
    _.isString(@id) and @id.length is 36 and @id.indexOf('t') == 0

  getStoreName = (collection, model) ->
    model ||= collection.model.prototype
    _.result(collection, 'storeName') || _.result(model, 'storeName') ||
    _.result(collection, 'url')       || _.result(model, 'urlRoot')   || _.result(model, 'url')

  # Make it easy for collections to sync dirty and destroyed records
  # Simply call collection.syncDirtyAndDestroyed()
  Backbone.Collection.prototype.syncDirty = (options) ->
    @dirtyModels().then (models) ->
      for m in models
        m.save(null, options)

  Backbone.Collection.prototype.dirtyModels = ->
    self = @
    storage.get("#{getStoreName(@)}_dirty").then (records) -> 
      records ||= []
    .then (records) -> 
      _.map records, (id) -> 
        m = self.get(id)
        # storage.remove("#{getStoreName(self)}#{id}") unless m
        # m
    .then (models) -> 
      _.compact(models)

  Backbone.Collection.prototype.syncDestroyed = (options) ->
    @destroyedModelIds().then (records) -> 
      records ||= []
    .then (records) ->
      for id in records
        model = new @model
        model.set model.idAttribute, id
        model.collection = @
        model.destroy(options)

  Backbone.Collection.prototype.destroyedModelIds = ->
    storage.get("#{getStoreName(@)}_destroyed").then (records) -> 
      records ||= []

  Backbone.Collection.prototype.syncDirtyAndDestroyed = (options) ->
    @syncDirty(options)
    @syncDestroyed(options)

  # Generate four random hex digits.
  S4 = ->
    (((1 + Math.random()) * 0x10000) | 0).toString(16).substring 1

  # Our Store is represented by a single JS object in *local storage*. Create it
  # with a meaningful name, like the name you'd give a table.
  class window.Store
    sep: '' # previously '-'

    constructor: (name) ->
      self = @
      @name = name
      @records = []
      @recordsOn(@name).then (rec) -> 
        self.records = rec

    # Generates an unique id to use when saving new instances into local storage
    # by default generates a pseudo-GUID by concatenating random hexadecimal.
    # you can overwrite this function to use another strategy
    generateId: ->
      't' + S4().substring(1) + S4() + '-' + S4() + '-' + S4() + '-' + S4() + '-' + S4() + S4() + S4()

    # Save the current state of the **Store** to *local Storage*.
    save: ->
      storage.set @name, @records

    recordsOn: (key) ->
      storage.get(key).then (records) ->
        records ||= []
        
    dirty: (model) ->
      self = @
      store = "#{@name}_dirty"
      @recordsOn(store).then (dirtyRecords) ->
        if not _.include(dirtyRecords, model.id.toString())
          dirtyRecords.push model.id
          storage.set store, dirtyRecords
      model

    clean: (model, from) ->
      self = @
      store = "#{@name}_#{from}"
      dirtyRecords = @recordsOn(store).then (dirtyRecords) ->
        
        if _.include dirtyRecords, model.id.toString()
          storage.set store, _.without(dirtyRecords, model.id.toString())

        if model.previousAttributes().id? and _.include dirtyRecords, model.previousAttributes().id.toString()
          storage.set store, _.without(dirtyRecords, model.previousAttributes().id.toString())

      model

    destroyed: (model) ->
      self = @
      store = "#{@name}_destroyed"
      @recordsOn(store).then (destroyedRecords) ->
        if not _.include destroyedRecords, model.id.toString()
          destroyedRecords.push model.id
          storage.set store, destroyedRecords
      model

    # Add a model, giving it a unique GUID, if it doesn't already
    # have an id of it's own.
    create: (model, options) ->
      if not _.isObject(model) then return model
      if not model.id
        model.set model.idAttribute, @generateId()
      storage.set @name + @sep + model.id, if model.toJSON then model.toJSON(options) else model
      @records.push model.id.toString()
      @save()
      model

    # Update a model by replacing its copy in `this.data`.
    update: (model, options) ->
      storage.set @name + @sep + model.id, if model.toJSON then model.toJSON(options) else model
      if not _.include(@records, model.id.toString())
        @records.push model.id.toString()
      @save()
      model

    clear: ->
      self = @
      @recordsOn(@name).then (records) ->
        for id in records
          storage.remove self.name + self.sep + id
      @records = []
      @save()

    # returns promise true / false
    hasDirtyOrDestroyed: ->
      Promise.all([storage.get(@name + '_dirty'), storage.get(@name + '_destroyed')]).then (resp) ->
        not _.isEmpty(resp[0]) or not _.isEmpty(resp[1])

    # Retrieve a model from `this.data` by id.
    find: (model) ->
      storage.get @name + @sep + model.id

    # Return the array of all models currently in storage.
    findAll: ->
      self = @
      @recordsOn(@name).then (records) ->
        # now we have all the record id, collect promisses for all the records
        ps = []
        for id in records
          ps.push storage.get(self.name + self.sep + id)
        Promise.all(ps) # returning all the promisses
      
    # Delete a model from `this.data`, returning it.
    destroy: (model) ->
      storage.remove @name + @sep + model.id
      @records = _.reject(@records, (record_id) ->
        record_id is model.id.toString()
      )
      @save()
      model


  window.Store.exists = (storeName, model) -> 
    storage.get(storeName).then (r) ->
      model._dual_store_exists = true if r?

  # Override `Backbone.sync` to use delegate to the model or collection's
  # *local Storage* property, which should be an instance of `Store`.
  localsync = (method, model, options) ->

    # console.log "Localsync #{method} for #{options.storeName}"

    isValidModel = (method is 'clear') or (method is 'hasDirtyOrDestroyed')
    isValidModel ||= model instanceof Backbone.Model
    isValidModel ||= model instanceof Backbone.Collection

    if not isValidModel
      throw new Error 'model parameter is required to be a backbone model or collection.'

    store = new Store options.storeName

    callback = (response) ->
      if response
        if response.toJSON
          response = response.toJSON(options)
        if response.attributes
          response = response.attributes

      unless options.ignoreCallbacks
        if response
          options.success response
        else
          options.error 'Record not found'

    return switch method
      when 'read'
        if model instanceof Backbone.Model
          console.warn "NOT TESTED"
          store.find(model).then callback
        else
          store.findAll().then callback
      when 'hasDirtyOrDestroyed'
        store.hasDirtyOrDestroyed().then callback
      when 'clear'
        store.clear()
      when 'create'
        if options.add and not options.merge 
          store.find(model).then (m) ->
            return m if m?
          
            model = store.create(model, options)
            store.dirty(model) if options.dirty
            model
        else
          model = store.create(model, options)
          store.dirty(model) if options.dirty
          model
      when 'update'
        store.update(model, options)
        if options.dirty
          store.dirty(model)
        else
          store.clean(model, 'dirty')
      when 'delete'
        console.warn "NOT TESTED"
        store.destroy(model)
        if options.dirty && !model.hasTempId()
          store.destroyed(model)
        else
          if model.hasTempId()
            store.clean(model, 'dirty')
          else
            store.clean(model, 'destroyed')

  # Helper function to run parseBeforeLocalSave() in order to
  # parse a remote JSON response before caching locally
  parseRemoteResponse = (object, response) ->
    if not (object and object.parseBeforeLocalSave) then return response
    if _.isFunction(object.parseBeforeLocalSave) then object.parseBeforeLocalSave(response)

  modelUpdatedWithResponse = (model, response) ->
    modelClone = new Backbone.Model
    modelClone.idAttribute = model.idAttribute
    modelClone.set model.attributes
    modelClone.set model.parse response
    modelClone

  backboneSync = Backbone.DualStorage.originalSync = Backbone.sync
  onlineSync = (method, model, options) ->
    error = options.error
  
    # Extend error method
    options.error = (resp, textStatus, errorThrown) ->
      error(resp) if error?
      # trigger errors, so if the model is on screen the errors will be visible.
      if resp.status == 422 and model instanceof Backbone.Model 
        model.setServerErrors resp.responseJSON
        model.trigger 'invalid' 

    Backbone.DualStorage.originalSync(method, model, options)

  dualsync = (method, model, options) ->
    options.storeName = getStoreName(model.collection, model)
    options.storeExists = Store.exists(options.storeName, model)
    
    # execute only online sync
    return onlineSync(method, model, options) if _.result(model, 'remote') or _.result(model.collection, 'remote')

    # execute only local sync
    local = _.result(model, 'local') or _.result(model.collection, 'local')
    options.dirty = options.remote is false and not local
    return localsync(method, model, options) if options.remote is false or local
    
    # execute dual sync
    options.ignoreCallbacks = true

    success = options.success
    error = options.error

    useOfflineStorage = ->
      options.dirty = true
      options.ignoreCallbacks = false
      options.success = success
      options.error = error
      localsync(method, model, options)

    hasOfflineStatusCode = (xhr) ->
      offlineStatusCodes = Backbone.DualStorage.offlineStatusCodes
      offlineStatusCodes = offlineStatusCodes(xhr) if _.isFunction(offlineStatusCodes)
      xhr.status == 0 or xhr.status in offlineStatusCodes

    relayErrorCallback = (xhr) ->
      online = not hasOfflineStatusCode xhr
      if online or method == 'read' and not options.storeExists
        error xhr
      else
        useOfflineStorage()

    switch method
      when 'read'
        localsync('hasDirtyOrDestroyed', model, options).then (hasDirty) -> 
          if hasDirty
            useOfflineStorage()
          else
            options.success = (resp, _status, _xhr) ->
              return useOfflineStorage() if hasOfflineStatusCode options.xhr
              resp = parseRemoteResponse(model, resp)

              if model instanceof Backbone.Collection
                collection = model
                idAttribute = collection.model.prototype.idAttribute
                localsync('clear', collection, options) unless options.add
                for modelAttributes in resp
                  model = collection.get(modelAttributes[idAttribute])
                  if model
                    responseModel = modelUpdatedWithResponse(model, modelAttributes)
                  else
                    responseModel = new collection.model(modelAttributes)
                  localsync('update', responseModel, options)
              else
                responseModel = modelUpdatedWithResponse(model, resp)
                localsync('update', responseModel, options)

              success(resp, _status, _xhr)

            options.error = (xhr) ->
              relayErrorCallback xhr

            options.xhr = onlineSync(method, model, options)

      when 'create'
        options.success = (resp, _status, _xhr) ->
          return useOfflineStorage() if hasOfflineStatusCode options.xhr
          updatedModel = modelUpdatedWithResponse model, resp
          localsync(method, updatedModel, options)
          success(resp, _status, _xhr)
        options.error = (xhr) ->
          relayErrorCallback xhr

        options.xhr = onlineSync(method, model, options)

      when 'update'
        if model.hasTempId()
          temporaryId = model.id

          options.success = (resp, _status, _xhr) ->
            model.set model.idAttribute, temporaryId, silent: true
            return useOfflineStorage() if hasOfflineStatusCode options.xhr
            updatedModel = modelUpdatedWithResponse model, resp
            localsync('delete', model, options)
            localsync('create', updatedModel, options)
            success(resp, _status, _xhr)
          options.error = (xhr) ->
            model.set model.idAttribute, temporaryId, silent: true
            relayErrorCallback xhr

          model.set model.idAttribute, null, silent: true
          options.xhr = onlineSync('create', model, options)
        else
          options.success = (resp, _status, _xhr) ->
            return useOfflineStorage() if hasOfflineStatusCode options.xhr
            updatedModel = modelUpdatedWithResponse model, resp
            localsync(method, updatedModel, options)
            success(resp, _status, _xhr)
          options.error = (xhr) ->
            relayErrorCallback xhr

          options.xhr = onlineSync(method, model, options)

      when 'delete'
        if model.hasTempId()
          options.ignoreCallbacks = false
          localsync(method, model, options)
        else
          options.success = (resp, _status, _xhr) ->
            return useOfflineStorage() if hasOfflineStatusCode options.xhr
            localsync(method, model, options)
            success(resp, _status, _xhr)
          options.error = (xhr) ->
            relayErrorCallback xhr

          options.xhr = onlineSync(method, model, options)

  Backbone.sync = dualsync