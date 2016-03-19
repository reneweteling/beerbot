# @cjsx React.DOM 
module.exports = React.createClass
  mixins: [backboneCollectionMixin]

  getInitialState: ->
    height: $(window).height() - 150
    items: @props.collection.where( project_id: CurrentUser.get('project_id') )
    filter: ''
    types: _.map UploadCollection.types, (name, key) ->
      label: name
      value: key

  setCollectionState: ->  
    @handleFilter(@state.filter)

  handleFilter: (value) ->
    args = 
      project_id: CurrentUser.get('project_id')
    args['type'] = value if value.length > 0

    @setState
      filter: value
      items: @props.collection.where args

    @refs.list.forceUpdate()

  componentDidMount: ->
    @props.collection.fetch
      remove: false
      data:
        project_id: CurrentUser.get 'project_id'

  handleTakePicture: (e) ->
    e.preventDefault()
    self = this

    if navigator? and navigator.camera?
      navigator.camera.getPicture(
        (path) ->

          new UploadCollection.model
            project_id: CurrentUser.get('project_id')
            type: self.state.filter
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

    unless m.get('path')
      file = <div key={key}>
        <span className="glyphicon glyphicon-picture" aria-hidden="true"></span>
      </div>
    else 
      if m.thumb()?
        file = <img src={m.thumb()} className="img-rounded img-responsive" />  
      else
        name = m.path().match(/^.*\/(.*)$/)[1].toLowerCase()
        file = <span>
          <span className="glyphicon glyphicon-file" aria-hidden="true"></span> {name}
        </span>

    <div className="col-xs-12" key={key}>
      <div className="panel panel-default" >
        <div className="panel-heading">
          <div className="panel-title">{m.get('id')} - {m.get('title')} 
            <span className="pull-right badge">
              {UploadCollection.types[m.get('type')]}
            </span>
          </div>
        </div>
        <div className="panel-body row">
          <div className="col-sm-8 col-xs-12">
            {m.get('description')}
          </div>
          <div className="col-sm-4 col-xs-12" onClick={openFile.bind(self, m)} >
            {file}
          </div>
        </div>
      </div>
    </div>

  render: ->

    select = <Select
        multiple={true} 
        options={@state.types}
        value={@state.filter}
        placeholder= "Toon alle bestanden"
        onChange={@handleFilter}
      />

    <div>
      {
        if @state.filter.length > 0
          <div className="row">
            <div className="col-xs-10">{select}</div>
            <div className="col-xs-2">
              <div className="form-group">
                <br />
                <div className="btn-group btn-group-sm pull-right" role="group">
                  <button type="button" className="btn btn-default" onClick={@handleTakePicture}><span className="glyphicon glyphicon-camera" aria-hidden="true"></span> Foto</button>
                </div>
              </div>
            </div>
          </div>
        else
          select
      }
      
      <div className="row scrollable" style={{ maxHeight: @state.height }}>
        { if @state.items.length == 0 then <h3 className="text-center">Er zijn geen bestanden gevonden</h3> }
        <ReactList ref="list"
          itemRenderer={@itemRenderer}
          length={@state.items.length} 
          type='simple'
          useTranslate3d={true}
        />
      </div>
    </div>