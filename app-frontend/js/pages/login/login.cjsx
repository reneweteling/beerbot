# @cjsx React.DOM 
module.exports = React.createClass
  mixins: [backboneModelMixin]
  login: (e) ->
    self = @
    e.preventDefault() if e
    @setModel()
    @props.model.signIn ->
      Router.navigate '/', {trigger: true}
    , ->
      self.setState
        error: true
        model:
          email: null
          password: null

  handleAlertDismiss: ->
      @setState(error: false) 

  handleRene: (e) ->
    self = @
    @setState
      model:
        email: 'rene@weteling.com'
        password: 'password'
        rememberme: true

    setTimeout -> 
      self.login()
    , 250

  render: ->
    error = <bs.Alert bsStyle="danger" onDismiss={this.handleAlertDismiss}>
      <h4>Inloggen mislukt</h4>
      <p>Gebruikersnaam wachtwoord combinatie niet gevonden.</p>
    </bs.Alert>

    <form onSubmit={@login} ref="form"> 
      {if @state.error then error else ''}
      <bs.Input name="email" type="email" label="Email Address" placeholder="Enter email" onChange={@changeField.bind(@, 'email')} value={@state.model.email} />
      <bs.Input name="password" type="password" label="Wachtwoord" onChange={@changeField.bind(@, 'password')} value={@state.model.password} />
      <bs.Input type="checkbox" label="Blijf ingelogd" onChange={@changeField.bind(@, 'rememberme')} checked={@state.model.rememberme} />
      <bs.ButtonInput type="submit" value="Login" />
      <div className="alert alert-info" role="alert">Huidige API: {apiUrl}</div>
      {if env == 'dev' then <bs.ButtonInput onClick={@handleRene} type="button" value="Login als Rene" />}
    </form>