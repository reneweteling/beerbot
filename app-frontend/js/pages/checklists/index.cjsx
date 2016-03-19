# @cjsx React.DOM 
module.exports = React.createClass
  mixins: [backboneCollectionMixin]
  
  getInitialState: ->
    height: $(window).height() - 200
    tabs: {
      'preparation': 'Voorbereiding',
      'daily' : 'Dagelijks',
      'cleanup' : 'Schoonmaak'
    }
    tab: 'daily'
    items: []
    
  setCollectionState: ->  
    @setMyState()

  setMyState: (props = @props) ->
    @setState
      tab: props.tab
      items: props.collection.where({ project_id: CurrentUser.get('project_id'), templatetype: props.tab })

    @refs.list.forceUpdate() if @refs.list?

  componentWillReceiveProps: (nextProps) ->
    @setMyState(nextProps)
    
  componentDidMount: ->
    self = @

    @props.collection.fetch
      remove: false
      data:
        project_id: CurrentUser.get 'project_id'
      success: ->
        self.setMyState()

    @setMyState()

  handleNew: (e) ->
    e.preventDefault()
    Router.navigate "/checklist/#{@state.tab}/new", {trigger: true}

  handleEdit: (m, e) ->
    e.preventDefault()
    Router.navigate "/checklist/#{@state.tab}/#{m.uid()}/edit", {trigger: true}

  handleTab: (tab, e) ->
    e.preventDefault()
    return Router.navigate "/checklist/#{tab}", {trigger: true}

  itemsRenderer: (items, ref) ->
    <table className="table table-condensed table-striped table-bordered">
      <thead>
        <tr>
          <th>Gebruiker</th>
          <th>Datum</th>
          <th>Acties</th>
        </tr>
      </thead>
      <tbody ref={ref} >
        {items}
      </tbody>
    </table>

  itemRenderer: (index, key) ->
    m = @state.items[index]
    <tr key={key}>
      <td>{m.userModel().to_s()}</td>
      <td>{dateFormat(m.get('updated_at'),'date_nl')}</td>
      <td><button className="btn btn-default btn-xs" onClick={@handleEdit.bind(@, m)}>Edit</button></td> 
    </tr>

  render: ->
    self = @
    selectedTitle = ''

    li = _.map @state.tabs, (title, tab) ->
      if self.state.tab == tab
        selectedTitle = title
        <li role="presentation" className="active" key={tab}><a>{title}</a></li>
      else
        <li role="presentation" className="pointer" key={tab} onClick={ self.handleTab.bind(self, tab) } ><a>{title}</a></li>

    <div>
      <ul className="nav nav-tabs">
        {li}
      </ul>
      <hr className="spacer" />
      <p>
        <button className="btn btn-primary btn-block" onClick={@handleNew} >Nieuwe checklist: {selectedTitle}</button>
      </p>
      <hr className="spacer" />
      { 
        if @state.items.length == 0  
          <h3 className="text-center">Er zijn geen checklists gevonden</h3>
        else
          <div className="table-responsive scrollable" style={{ maxHeight: @state.height }}>
            <ReactList ref="list"
              itemsRenderer={@itemsRenderer}
              itemRenderer={@itemRenderer}
              length={@state.items.length} 
              type='simple'
              useTranslate3d={true}
            />
          </div>
      }
    </div>