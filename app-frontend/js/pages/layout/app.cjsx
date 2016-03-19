# @cjsx React.DOM 
LoginPage          = require '../login/login.cjsx'

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
      else 
        <div className="panel panel-warning">
          <div className="panel-heading">
            <h3 className="panel-title">Pagina niet gevonden</h3>
          </div>
          <div className="panel-body">
            Helaas deze pagina is niet gevonden.
          </div>
        </div>
    
    return <div>
      <div className="container-fluid main-content">
        {content}
      </div>
    </div>