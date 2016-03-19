# @cjsx React.DOM 
module.exports = React.createClass
  mixins: [backboneCollectionMixin]
  
  getInitialState: ->
    height: $(window).height() - 150
    items: @props.collection.where( project_id: CurrentUser.get('project_id') )
  
  setCollectionState: ->
    @setState
      items: @props.collection.where( project_id: CurrentUser.get('project_id') )

  componentDidMount: ->
    @props.collection.fetch
      data:
        project_id: CurrentUser.get 'project_id'

  handleNew: (e) ->
    e.preventDefault()
    Router.navigate "/hours/new", {trigger: true}

  handleEdit: (m, e) ->
    e.preventDefault()
    return Router.navigate "/hours/#{m.uid()}/edit", {trigger: true}
  
  handleSign: (m, e) ->
    e.preventDefault()
    return Router.navigate "/hours/#{m.uid()}/sign", {trigger: true}

  itemsRenderer: (items, ref) ->
    <table className="table table-condensed table-striped table-bordered">
      <thead>
        <tr>
          <th>#</th>
          <th>Gebruiker</th>
          <th>Datum Start Eind</th>
          <th>Acties</th>
          <th>Getekend</th>
        </tr>
      </thead>
      <tbody ref={ref} >
        {items}
      </tbody>
    </table>

  itemRenderer: (index, key) ->
    m = @state.items[index]
    end = if m.get('end_at')? then dateFormat(m.get('end_at'),'time') else '??'

    sign = <button className="btn btn-default btn-xs" onClick={@handleSign.bind(@, m)}>Teken</button>
    if m.get('signature_data')
      sign = <span>ok</span>

    <tr key={key}>
      <td>{if isNaN(m.get('id')) then '?' else m.get('id')}</td>
      <td>{m.userModel().to_s()}</td>
      <td><nobr>{dateFormat(m.get('start_at'),'datetime_nl')}-{end}</nobr></td> 
      <td><button className="btn btn-default btn-xs" onClick={@handleEdit.bind(@, m)}>Edit</button></td> 
      <td>{sign}</td> 
    </tr>

  render: ->
    <div>
      <p>
        <button className="btn btn-primary btn-block" onClick={@handleNew} >Nieuw</button>
      </p>
      { 
        if @state.items.length == 0  
          <h3 className="text-center">Er zijn geen uren gevonden</h3>
        else
          <div className="table-responsive scrollable" style={{ maxHeight: @state.height }}>
            <ReactList
              itemsRenderer={@itemsRenderer}
              itemRenderer={@itemRenderer}
              length={@state.items.length} 
              type='simple'
              useTranslate3d={true}
            />
          </div>
      }
    </div>