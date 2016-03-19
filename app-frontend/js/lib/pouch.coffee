PouchDB = require 'pouchdb'
PouchDB.plugin require('pouchdb-find')
PouchDB.plugin require('pouchdb-upsert')
# PouchDB.debug.enable('*')
PouchDB.debug.disable()


window.resetPouch = (success=->) ->
  console.log "Reset db...."
  if db?
    db.destroy().then ->
      createPouch success
  else 
    createPouch success

window.createPouch = (success=->) ->  
  console.log 'setting up db....'

  window.db = new PouchDB
    name: 'horyon'
    adapter: 'websql'
    revs_limit: 1

  # db.info().then(console.log.bind(console)) 

  db.createIndex
    index:
      fields: ['-dirty']

  db.createIndex
    index:
      fields: ['-table', '-id']

  db.createIndex(
    index:
      fields: ['-table']
  ).then( (result) ->
    if result.result == 'exists'
      success()
    else
      setTimeout ->
        success()
      , 500
  ).catch (err) ->
    console.error err

window.hydrateCollections = ->
  console.log 'hydrating....'

  db.allDocs
    include_docs: true
  .then (result) ->
    docs = result.rows.map (row) -> row.doc
    groups = _.groupBy docs, (doc) -> doc['-table']
    
    for group, rows of groups
      continue unless group in _.keys(collections)
      collections[group].add rows

    console.log 'booting....'
    boot() 

storeInPouch = (model, table, dirty = true, remote = false, obj, objarg ) ->
  return unless model?

  model.set 
    '-table': table
    '-dirty': dirty

  updoc = (doc) ->
    doc = $.extend(model.attributes, doc)
    doc['-count'] ||= 0
    doc['-count'] = doc['-count'] + 1
    doc

  if model.attributes._id? # update
    db.get model.attributes._id, (err, doc) ->

      attr = model.attributes
      attr._rev = doc._rev

      db.put(attr).then (response) ->
        model.set '_rev', response.rev
        Backbone.ajaxSync.apply(obj, objarg) if remote
      .catch (err) ->
        if err.status == 409
          db.upsert(attr._id, updoc).then (resp) ->
            model.set '_rev', resp.rev
          .catch (err) ->
            console.warn err
        else
          console.warn [err, "#{attr._id} #{attr._rev} / #{model.attributes._rev} / #{doc._rev}" , model.attributes, doc]
  else # create
    db.post(model.attributes).then (response) ->
      # console.log "Insert"
      model.set 
        '_id': response.id
        '_rev': response.rev
      Backbone.ajaxSync.apply(obj, objarg) if remote
    .catch (err) ->
      console.warn(err)

Backbone.ajaxSync = Backbone.sync

Backbone.sync = (method, model, options={}) ->
  if @remote == true
    Backbone.ajaxSync.apply(@, arguments)
    return

  local = @remote == false
  local = options.local if options.local?

  self = @   
  selfarg = arguments

  # console.log [@, method, model, options]
  table = @table
  unless @table?
    urlRoot = if @urlRoot? then @urlRoot else @url()
    table = urlRoot.replace(apiUrl,'')

  success = selfarg[2].success
  error = selfarg[2].error
  
  # todo, alert and destory or something?
  selfarg[2].error = (response, errtext, httperrortext) ->
    error(arguments) if error?
    if response.status == 422
      # trigger errors, so if the model is on screen the errors will be visible.
      model.setServerErrors response.responseJSON
      model.trigger 'invalid' 

      # server doenst accept the input, remove the local version
      delete_by_id model.get('_id')
      model.unset ['_id', '_rev']

      if Router.model != model
        # Todo
        # - Alert the user that this has happend! modal whatever
        console.error "Model removed, and its not active"

      
  switch method
    when 'create', 'update'
      # success callback backbone syn, store the changes to couch
      selfarg[2].success = (resp) ->
        success(arguments)
        storeInPouch(model, table, false, false)
      
      storeInPouch(model, table, (if local then false else true), (if local then false else true), self, selfarg)
    when 'read'

      console.log "READ"

      selfarg[2].success = (resp) ->
        unless options.remove == false
          console.log "RESET"
          db.find
            selector: {'-table': table}
          .then (result) ->
            if result? and result.docs?
              _.map(result.docs, (d) -> delete_by_id d._id )

              docs = _.map(result.docs, (d) -> {_deleted: true, _id: d._id} )
              db.bulkDocs( docs ).then ->
                console.log "DONE"
                console.log resp
                success.call(self, resp)
                if resp?
                  for mod in resp.models
                    m1 = self.get(mod.id)
                    m1.unset ['_id', '_rev']
                    storeInPouch(m1, table, false)
            else 
              if resp?
                for mod in resp.models
                  m1 = self.get(mod.id)
                  m1.unset ['_id', '_rev']
                  storeInPouch(m1, table, false)


      db.find
        selector: {'-table': table}
      .then (result) ->
        
        # add found models to collection
        newDocs = []
        for doc in result.docs

          m = self.get(doc.id)
          m = self.findWhere({'_id': doc._id}) unless m
          if m
            m.set doc
          else
            newDocs.push doc
        
        self.add newDocs
        options.success.call(self) #unless online

        Backbone.ajaxSync.apply(self, selfarg) unless local

      .catch (err) ->
        console.error err
    when 'patch' 
      console.log 'patch'
    when 'delete' 
      # Delete from Backend
      Backbone.ajaxSync.apply(self, selfarg) unless local

      # Delete from pouch
      delete_by_id model.attributes._id if model.attributes._id
      
delete_by_id = (id) ->
  console.warn "Deleting #{id}"
  db.get id, (err, doc) ->
    db.remove(doc, (err, resp) -> console.error err if err) unless err

window.countAndSetDirty = ->
  return unless CurrentUser.signedIn()

  db.find
    selector: {'-dirty': true}
  .then (result) ->
    CurrentUser.set 'dirty_total', result.docs.length
    CurrentUser.set 'dirty', 0

    return unless result.docs.length > 0

    if CurrentUser.get('online') == true
      groups = _.groupBy result.docs, (doc) -> doc['-table']

      for group, rows of groups
        collection = collections[group]

        for row in rows
          m = collection.get(row.id)
          m = collection.findWhere({'_id': row._id}) unless m?

          # # remove rows without a model, or the _id dont match ( double )
          # if !m? or m.get('_id') != row._id
          #   console.log m if m?
          #   console.log m.get('_id') if m?
          #   delete_by_id row._id
          #   continue
          
          m.save null, 
            success: ->
              CurrentUser.set 'dirty', CurrentUser.get('dirty') + 1

  .catch (err) -> 
    console.error err

dirtyTimer = setInterval countAndSetDirty, 5000   
