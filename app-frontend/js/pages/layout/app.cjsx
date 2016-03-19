# @cjsx React.DOM 
window.Select      = require '../../components/select.cjsx'
window.Modal       = require '../../components/modal.cjsx'
LoginPage          = require '../login/login.cjsx'
ProjectIndex       = require '../projects/index.cjsx'
DiaryIndex         = require '../diaries/index.cjsx'
HourIndex          = require '../hours/index.cjsx'
HourEdit           = require '../hours/edit.cjsx'
HourSign           = require '../hours/sign.cjsx'
ExposureIndex      = require '../exposure_hours/index.cjsx'
ExposureEdit       = require '../exposure_hours/edit.cjsx'
ChecklistIndex     = require '../checklists/index.cjsx'
ChecklistEdit      = require '../checklists/edit.cjsx'
FilesIndex         = require '../files/index.cjsx'

module.exports = React.createClass
  componentWillMount: ->
    self = @
    @callback = ( ->
      @forceUpdate()
    ).bind(@)
    @props.router.on("route", @callback)
    
    CurrentUser.on "change", (user_model) ->
      self.setState (user_model || CurrentUser).attributes
  
  getInitialState: ->
    state = CurrentUser.attributes
    state.expanded = false
    state.modal ||= 
      open: false
      title: ''
      body: ''
      buttons: {}
    
    state

  componentWillUnmount: ->
    @props.router.off("route", @callback)
    clearInterval @periodicActionTimer
  
  handleSyncClick: ->
    sync.withServer()
    
  handleToggle: ->
    @setState({ expanded: !@state.expanded })

  handleClick: (path,e) ->
    e.preventDefault()
    @setState({ expanded: false })
    @props.router.navigate path, {trigger: true}
    
  render: ->
    a = @props.router.current

    content = switch 
      when a == 'login'         
        <LoginPage model={CurrentUser} />
      when a == 'hourIndex'
        <HourIndex collection={@props.router.collection} />
      when a == 'hourEdit'
        <HourEdit model={@props.router.model} />
      when a == 'hourSign'
        <HourSign model={@props.router.model} />
      when a == 'exposureIndex'
        <ExposureIndex collection={@props.router.collection} user={@props.router.user} />
      when a == 'exposureEdit'
        <ExposureEdit model={@props.router.model} />
      when a == 'projectIndex'
        <ProjectIndex collection={@props.router.collection} />
      when a == 'diaryIndex'
        <DiaryIndex collection={@props.router.collection} />
      when a == 'checklistIndex'
        <ChecklistIndex collection={@props.router.collection} tab={@props.router.tab} />
      when a == 'checklistEdit'
        <ChecklistEdit model={@props.router.model} tab={@props.router.tab} />
      when a == 'filesIndex'
        <FilesIndex collection={@props.router.collection} />

      else 
        <div className="panel panel-warning">
          <div className="panel-heading">
            <h3 className="panel-title">Pagina niet gevonden</h3>
          </div>
          <div className="panel-body">
            Helaas deze pagina is niet gevonden.
          </div>
        </div>
          
    if CurrentUser.signedIn()
      
      if CurrentUser.project()?
        nav = <bs.Nav>
          <bs.NavItem onClick={@handleClick.bind(@, 'projects')}>Projecten</bs.NavItem>
          <bs.NavItem onClick={@handleClick.bind(@, 'diary')}>Dagboek</bs.NavItem>
          <bs.NavItem onClick={@handleClick.bind(@, 'files')}>Bestanden</bs.NavItem>
          <bs.NavItem onClick={@handleClick.bind(@, 'hours')}>Uren</bs.NavItem>
          <bs.NavItem onClick={@handleClick.bind(@, 'exposure')}>Blootstellingsuren</bs.NavItem>
          <bs.NavItem onClick={@handleClick.bind(@, 'checklist')}>Checklist</bs.NavItem>
          <bs.NavItem divider />
          <bs.NavItem onClick={@handleClick.bind(@, 'logout')}>logout</bs.NavItem>
        </bs.Nav>
      else
        nav = <bs.Nav> 
          <bs.NavItem onClick={@handleClick.bind(@, 'logout')}>logout</bs.NavItem>
        </bs.Nav>
    else
      nav = <bs.Nav>
        <bs.NavItem onClick={@handleClick.bind(@, 'login')}>login</bs.NavItem>
      </bs.Nav>

    p = ProjectCollection.get(CurrentUser.get('project_id'))
    title = 'Horyon'
    title = "#{title} - #{p.get('key')}" if p

    footer = 
      open: false
      dirty:
        total: @state.dirty_total ||= 0
        done: @state.dirty ||= 0
      downloads:
        total: @state.download_total ||= 0
        done: @state.download ||= 0

    footer.dirty.percent = Math.ceil(((footer.dirty.done+1)/footer.dirty.total) * 100)
    footer.downloads.percent = Math.ceil(((footer.downloads.done+1)/footer.downloads.total) * 100)
    footer.open = true if (footer.dirty.total != footer.dirty.done) or (footer.downloads.total != footer.downloads.done)

    # console.log "dirty: #{footer.dirty.done}/#{footer.dirty.total} | downloads: #{footer.downloads.done}/#{footer.downloads.total}" 
    

    return <div className="fullHeight">
      <bs.Navbar inverse fixedTop className={ if @state.online then 'online' else 'offline' } expanded={@state.expanded} onToggle={->}>
        <bs.Navbar.Header>
          <bs.Navbar.Brand>
            <a onClick={@handleClick.bind(@, 'projects')} >{title}</a>
          </bs.Navbar.Brand>
          <div onClick={@handleToggle} >
            <bs.Navbar.Toggle />
          </div>
        </bs.Navbar.Header>

        <bs.Navbar.Collapse>
          {nav}
        </bs.Navbar.Collapse>
      </bs.Navbar>
      
      <div className="container-fluid main-content">
        {content}
      </div>

      <footer className={ if footer.open then 'open' else 'closed' } >
        <div className={ if footer.dirty.total != footer.dirty.done then 'progress' else 'hidden' }>
          <div className="progress-bar progress-bar-striped" role="progressbar" style={{ width: "#{footer.dirty.percent}%" }} >
            {"Syncen #{footer.dirty.done}/#{footer.dirty.total}"}
          </div>
        </div>
        <div className={ if footer.downloads.total != footer.downloads.done then 'progress' else 'hidden' }>
          <div className="progress-bar progress-bar-striped" role="progressbar" style={{ width: "#{footer.downloads.percent}%" }} >
            {"Downloads #{footer.downloads.done}/#{footer.downloads.total}"}
          </div>
        </div>
      </footer>
      {
        if @state.modal?
          <Modal open={@state.modal.open} title={@state.modal.title} body={@state.modal.body} buttons={@state.modal.buttons} />
      }
    </div>
