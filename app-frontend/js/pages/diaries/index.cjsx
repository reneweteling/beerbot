# @cjsx React.DOM 
module.exports = React.createClass
  mixins: [backboneCollectionMixin]

  getInitialState: ->
    value: ''
    height: $(window).height() - 270
    items: @props.collection.where( project_id: CurrentUser.get('project_id') )

  setCollectionState: ->  
    @setState
      items: @props.collection.where( project_id: CurrentUser.get('project_id') )
    @refs.list.forceUpdate()

  componentDidMount: ->
    @props.collection.fetch
      data:
        project_id: CurrentUser.get 'project_id'

  handleBodyChange: ->
    @setState
      value: @refs.body.refs.input.value

  handleSubmit: (e) ->
    e.preventDefault() 
    if @state.value.length > 0
      @props.collection.create
        user_id: CurrentUser.get 'id' 
        project_id: CurrentUser.get 'project_id' 
        description: @state.value
        diary_uploads: []

    @setState
      value: ''
    
    false

  handleTakePicture: (m, e) ->
    e.preventDefault()
    self = this

    @setState
      picModel: m

    if navigator? and navigator.camera?
      navigator.camera.getPicture(
        (path) ->

          new UploadCollection.model
            project_diary_id: m.id
            type: 'DiaryUpload'
            upload_path: path

        ,(msg) ->
          console.error msg
        ,{ 
          quality: 70,
          destinationType: Camera.DestinationType.FILE_URI
        }
      )     

    
  itemRenderer: (index, key) ->
    m = @state.items[index]
    self = @

    images = m.get('diary_uploads').map (f) ->
      if UploadCollection.size() > 0
        fm = UploadCollection.get(f.id)

      if fm?
        <div className="col-xs-6 col-md-3" key="opload-#{fm.id}" onClick={openFile.bind(self, fm)} >
          <img src={fm.thumb()} className="img-thumbnail" />
        </div> 
      else
        <div className="col-xs-6 col-md-3" key="opload-#{f.id}" >
          <span className="glyphicon glyphicon-save" aria-hidden="true"></span> Afbeelding laden....
        </div> 


    <div className="col-xs-12" key={key}>
      <div className="panel panel-default" >
        <div className="panel-heading">
          <div className="panel-title">{dateFormat(m.get('created_at'),'datetime_nl')} - {m.userModel().to_s()}</div>
        </div>
        <div className="panel-body">
          {m.get('description')}
          <hr />
          <div className="row">
            {images}
          </div>
          
          <button type="button" className="btn btn-default pull-right" onClick={@handleTakePicture.bind(@, m)}>
            <span className="glyphicon glyphicon-camera" aria-hidden="true"></span> Voeg toe
          </button>
          
        </div>
      </div>
    </div>

  render: ->
    <div>
      <form style={{ display: 'none' }} >
        <input type="file" ref="upload" onChange={@handleFileUpload} />
      </form>
      <form name="form" onSubmit={@handleSubmit}> 
        <bs.Input name="body" type="textarea" label="Nieuw dagboek item" placeholder="" ref="body" value={@state.value} onChange={@handleBodyChange} />
        <bs.ButtonInput type="submit" value="Voeg toe" onClick={@handleSubmit} />
      </form>
      <hr />
      <div className="row scrollable" style={{ maxHeight: @state.height }}>
        { if @state.items.length == 0 then <h3 className="text-center">Er zijn geen dagboek items gevonden</h3> }
        <ReactList ref="list"
          itemRenderer={@itemRenderer}
          length={@state.items.length} 
          type='simple'
          useTranslate3d={true}
        />
      </div>
    
    </div>