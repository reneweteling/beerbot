# @cjsx React.DOM 
module.exports = React.createClass
  mixins: [backboneCollectionMixin]
  
  getInitialState: ->
    height: $(window).height() - 200
    items: []
    users: []
    
  setCollectionState: ->  
    @setMyState()

  setMyState: (props = @props) ->
    hours = HourCollection.where({project_id: CurrentUser.get('project_id')})
    users = _.uniq hours.map (m) -> m.userModel()
    user_ids = _.uniq users.map (m) -> m.id

    user = users[0]
    if props.user
      user = props.user

    return unless user

    # filter the collection for this user
    items = props.collection.filter (m) ->
      parseInt(user.id) == parseInt(m.hourModel().get('user_id'))

    # the the currnt available timespan
    now = Date.parse(new Date())
    current_hour = HourCollection.where({project_id: CurrentUser.get('project_id'), user_id: user.uid()}).filter (m) ->
      Date.parse(m.get('start_at')) < now and (m.get('end_at')? == false or Date.parse(m.get('end_at')) > now)

    # get the running exposure hour
    current_exposure = items.filter (m) ->
      !m.get('end_at')?
      # Date.parse(m.get('start_at')) <= now and m.get('end_at')? == false

    @setState
      items: items
      users: users
      user: user
      hour: current_hour[0] if current_hour
      exposure: current_exposure[0] if current_exposure

    @refs.list.forceUpdate() if @refs.list?

  componentWillReceiveProps: (nextProps) ->
    @setMyState(nextProps)
    
  componentDidMount: ->
    self = @
    
    HourCollection.fetch
      data:
        project_id: CurrentUser.get 'project_id'
      
    @props.collection.fetch
      data:
        project_id: CurrentUser.get 'project_id'
      success: ->
        self.setMyState()

    @setMyState()

  handleStart: (e) ->
    e.preventDefault()

    ExposureHourCollection.create
      user_id : @state.user.uid()
      hour_id : @state.hour.uid()
      start_at : new Date().toISOString()
      risk_category : '2'
    
    @setMyState()
    
  handleStop: (e) ->
    e.preventDefault()
    @state.exposure.set
      end_at: new Date().toISOString()
    @setMyState()
    @state.exposure.save()

  handleNew: (e) ->
    e.preventDefault()
    Router.navigate "exposure/user-#{@state.user.uid()}/new", {trigger: true}

  handleEdit: (m, e) ->
    e.preventDefault()
    Router.navigate "/exposure/#{m.uid()}/edit", {trigger: true}

  handleTab: (m, e) ->
    e.preventDefault()
    return Router.navigate "/exposure/user-#{m.uid()}", {trigger: true}

  itemsRenderer: (items, ref) ->
    <table className="table table-condensed table-striped table-bordered">
      <thead>
        <tr>
          <th>Datum</th>
          <th>Start</th>
          <th>Eind</th>
          <th>Risicoklasse</th>
          <th>Acties</th>
        </tr>
      </thead>
      <tbody ref={ref} >
        {items}
      </tbody>
    </table>

  itemRenderer: (index, key) ->
    m = @state.items[index]
    end = if m.get('end_at')? then dateFormat(m.get('end_at'),'time') else '??'
    <tr key={key}>
      <td>{dateFormat(m.get('start_at'),'date_nl')}</td>
      <td>{dateFormat(m.get('start_at'),'time')}</td>
      <td>{end}</td>
      <td>{m.get('risk_category')}</td>
      <td><button className="btn btn-default btn-xs" onClick={@handleEdit.bind(@, m)}>Edit</button></td> 
    </tr>

  render: ->
    self = @

    li = @state.users.map (m) ->
      if self.state.user == m
        <li role="presentation" className="active text-center" key={"u_#{m.uid()}"}><a>{m.get('first_name')}<br />{m.get('last_name')}</a></li>
      else
        <li role="presentation" className="pointer text-center" key={"u_#{m.uid()}"} onClick={ self.handleTab.bind(self, m) } ><a>{m.get('first_name')}<br />{m.get('last_name')}</a></li>

    buttons = 
      if @state.hour? or true
        # end = if @state.hour.get('end_at')? then dateFormat(@state.hour.get('end_at'),'time') else '??'
        # <div className="col-xs-12">
        #     <p className="text-center bg-info">{"#{dateFormat(@state.hour.get('start_at'),'time')} - #{end}"}</p>
        #   </div>
        <div>
          <div className="col-xs-6">
            <button className="btn btn-primary btn-block" onClick={@handleNew} >Nieuw</button>
          </div>
          <div className="col-xs-6">
            {
              if @state.hour?
                if @state.exposure?
                  <button className="btn btn-danger btn-block" onClick={@handleStop} >Stop</button>
                else
                  <button className="btn btn-success btn-block" onClick={@handleStart} >Start</button>
            }
          </div>
        </div>
      else if @state.user
        <div className="col-xs-12">
          <p className="text-center bg-danger">{ @state.user.get('first_name') } is niet actief op dit project.</p> 
        </div>
        

    <div>
      <ul className="nav nav-tabs">
        {li}
      </ul>
      <hr className="spacer" />
      <div className="row">
        {buttons}
      </div>
      <hr className="spacer" />
      { 
        if @state.items.length == 0 
          <h3 className="text-center">Er zijn geen blootstellingsuren gevonden</h3> 
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