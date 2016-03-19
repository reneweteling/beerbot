module.exports = require('./base.coffee').extend
  types: 
    NotificationUpload: 'Meldingen',
    LicenseUpload: 'Vergunningen',
    StockUpload: 'Inventarisaties',
    WorkplanUpload: 'Werkplannen',
    ReleaseUpload: 'Vrijgaves',
    DumplicenseUpload: 'Stortbewijzen',
    MiscUpload: 'Overige',
    DiaryUpload: 'Dagboek'
  removeOrphans: ->
    deleteable = @filter (m) -> !m.get('url')? && !m.get('path')? && !m.get('upload_path')?
    for m in deleteable
      m.destroy
        local: true

  comparator: (a,b) ->
    if a.attributes.type != b.attributes.type
      return if @types[a.attributes.type] > @types[b.attributes.type] then -1 else 1
    
    return if a.id > b.id then -1 else 1

  model: require('../models/base.coffee').extend
    urlRoot: "#{apiUrl}uploads"
    
    
    thumb: ->
      if cordova?
        @get('path_thumb')
      else
        @get('thumb')

    path: ->
      if cordova?
        @get('path')
      else
        @get('url')

    constructor: ->
      # trigger download / upload
      if FileTransfer?
        @on 'change', (model) ->
          if model.get('upload_path')? 
            model.upload() 
          else if !model.get('path')?
            model.download()

        

      Backbone.Model.apply(@, arguments)

    upload: ->
      self = @
      path = @get 'upload_path' 
      
      return if @get('uploading') == true
      return unless path?

      @set 
        uploading: true

      console.log "Starting upload for #{@id}"

      options = 
        chunkedMode: false # needs to be on, ssl post issue
        fileKey: "file"
        fileName: path.substr(path.lastIndexOf('/') + 1)
        mimeType: "text/plain"
        httpMethod : "POST" 
        headers : {
          'X-User-Token': CurrentUser.get('auth_token')
          'X-User-Email': CurrentUser.get('email')
        }
        params: @attributes

      options.httpMethod = "PUT" unless @isNew()

      
     
      ft = new FileTransfer()
      ft.upload path, encodeURI(@url()), (resp) ->
        
        # success, store re the result
        UploadCollection.add self
        self.unset 'upload_path' 
        self.unset 'uploading'
        self.save JSON.parse( resp.response )

        # console.log ["Saving response", self.attributes ]

        # download it again from the server for thumbs etc.
        self.download()
        
      , (error) ->  
        if error.code == 1 # file not found
          self.destroy()
        else
          console.log error
          self.unset 'uploading'
      , options

    download: ->
      self = @
      return if @get('path')? or @get('downloading')?
      return unless @get('url')?
      
      @set 
        downloading: true

      CurrentUser.set( 'download_total', CurrentUser.get('download_total') + 1)
      # console.log "Starting download for #{@id}"

      fileTransfer = new FileTransfer()

      filename = @get('url').match(/^.*\/(.*)$/)[1]
      filename = "#{cordova.file.externalApplicationStorageDirectory}#{@get('id')}-#{filename}"


      # download file
      fileTransfer.download encodeURI(@get('url')), filename,
        (entry) -> 

          self.save 
            path: entry.toURL()
          self.unset 'downloading'

          # tirgger the diary collection
          if self.get('project_diary_id')?
            ProjectDiaryCollection.fetch
              remove: false
              data:
                project_id: CurrentUser.get 'project_id'
            
          CurrentUser.set( 'download', CurrentUser.get('download') + 1)
          # console.log "Finished download for #{self.id}"
        ,
        (error) ->
          console.error error
          self.unset 'downloading'
          CurrentUser.set( 'download', CurrentUser.get('download') + 1)
        ,
        false

      # download thumb
      return unless @get('thumb')

      filename_thumb = @get('thumb').match(/^.*\/(.*)$/)[1]
      filename_thumb = "#{cordova.file.externalApplicationStorageDirectory}#{@get('id')}-#{filename_thumb}"

      fileTransfer.download encodeURI(@get('thumb')), filename_thumb,
        (entry) -> 
          self.save 
            path_thumb: entry.toURL()

          # console.log "Finished thumb for #{self.id}"
        ,
        (error) -> console.error error
        , false



    # downloadFiles: ->
    #   uploads = @attributes.uploads

    #   ids = _.pluck(uploads, 'id')
      
    #   # Update / Destory existing
    #   for existing in UploadCollection.where({ project_id: @get('id') })
    #     remotefile = _.findWhere(uploads, id: existing.get('id'))
    #     if remotefile? and existing.get('updated_at') == remotefile.updated_at
    #       # console.log "#{existing.get('updated_at')} == #{remotefile.updated_at}"  
    #       existing.save  
    #         title: remotefile.title
    #         description: remotefile.description
    #     else
    #       console.log "destory"
    #       existing.destroy()

    #   file_ids = _.pluck( UploadCollection.where({ project_id: @get('id') }), 'id' )

    #   # insert new
    #   for i, upload of uploads
    #     continue if _.contains(file_ids, upload.id)
    #     UploadCollection.create upload

    #   # set the download total
    #   total = 0
    #   CurrentUser.set 'download_total', total
    #   CurrentUser.set 'download', 0

    #   files = UploadCollection.where({ project_id: @get('id') })

    #   # download the files
    #   for i, file of UploadCollection.where({ project_id: @get('id') })
    #     continue if file.get('path')?
    #     total += 1
    #     file.download()

    #   CurrentUser.set 'download_total', total

    #   total
    
        
        


      