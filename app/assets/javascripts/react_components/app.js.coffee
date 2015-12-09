# Constants (Action types)
constants =
  DRINK_BEER: 'DRINK_BEER'
  BUY_BEER: 'BUY_BEER'

# Stores
BeerStore = Fluxxor.createStore
  initialize: ->
    @users = {}
    @stats = {}
    @getFromApi()
    @bindActions(constants.DRINK_BEER, @drinkBeer,
                 constants.BUY_BEER,   @drinkBeer)
    
  getFromApi: ->
    self = @
    $.getJSON "/beers", (data) -> 
      self.updateData data

  updateData: (data) ->
    @users = data.users
    @stats = data.stats
    @emit 'change'

  drinkBeer: (payload, type) ->
    window.audio_beer.load()
    window.audio_beer.play()
    payload.amount = payload.amount * -1 if type == constants.BUY_BEER
    self = @
    $.post "/beers", { beer: {user_id: payload.user.id, amount: payload.amount} }, (data) ->
      self.updateData data      
    , "json"
  
  getState: -> 
    users: @users
    stats: @stats


# Semantic actions
actions =
  drinkBeer: (user, amount)      -> @dispatch constants.DRINK_BEER, user: user, amount: amount
  drinkBeer: (user, amount)      -> @dispatch constants.BUY_BEER, user: user, amount: amount

stores = { BeerStore: new BeerStore }
flux = new Fluxxor.Flux(stores, actions)

FluxMixin = Fluxxor.FluxMixin(React)
StoreWatchMixin = Fluxxor.StoreWatchMixin

# React store's
Application = React.createClass
  mixins: [ReactRouter.Navigation, FluxMixin, StoreWatchMixin("BeerStore")]

  getStateFromFlux: ->
    flux = @getFlux()
    flux.store('BeerStore').getState()

  handleClick: ->
    @transitionTo 'drinking'

  render: ->
    users = @state.users
    <table className="table table-striped table-condensed" onClick={this.handleClick}>
      <thead>
        <tr>
          <th>User</th>
          <th>Consumed</th>
          <th>Bought</th>
          <th>Total</th>
        </tr>
      </thead>
      <tbody>
        {
          Object.keys(users).map (i) ->
            user = users[i]
            <tr key={user.id}>
              <td>{user.first_name}</td>
              <td>{user.beer_consumed}</td>
              <td>{user.beer_bought}</td>
              <td>{user.beer_total}</td>
            </tr>
        }
      </tbody>
    </table>
  

DrinkBeer = React.createClass
  mixins: [ReactRouter.Navigation, FluxMixin]

  handleClick: (user) ->
    @getFlux().actions.drinkBeer(user, 1)
    @transitionTo 'home'
  
  render: ->
    users = @props.users
    self = @
    <div>
      <h1 className="text-center">Keep on pouring!</h1>
      {
        Object.keys(users).map (i) ->
          user = users[i]
          <button className="btn btn-info btn-lg" key={i} type="submit" onClick={self.handleClick.bind(self, user)} >{user.first_name}</button>
      }
    </div>

BuyBeer = React.createClass
  mixins: [ReactRouter.Navigation, FluxMixin]

  handleClick: (user) ->
    @getFlux().actions.drinkBeer(user, -6)
    @transitionTo 'home'
  
  render: ->
    users = @props.users
    self = @

    <div>
      <h1 className="text-center">Thanks mate! So nice!! You buy 6 at a time!</h1>
      {
        Object.keys(users).map (i) ->
          user = users[i]
          <button className="btn btn-success btn-lg" key={i} type="submit" onClick={self.handleClick.bind(self, user)} >{user.first_name}</button>
      }
    </div>

GraphBeer = React.createClass
  mixins: [ReactRouter.Navigation, FluxMixin]
  
  render: ->
    self = @
    
    stats = []
    for n in @props.stats
      if stats[n.date]
        stats[n.date].values.push
          x: n.first_name
          y: n.total
      else
        stats[n.date] = 
          label: n.date
          values: [
            x: n.first_name
            y: n.total
          ]

    data = []
    for k,v of stats
      users = v.values.map (v) -> v.x
      for user in @props.users
        if users.indexOf(user.first_name) == -1
          v.values.push
            x: user.first_name
            y: 0
      data.push v
      
    if data.length > 0
      console.log data
      <ReactD3.BarChart
        groupedBars
        data={data}
        width={600}
        height={400}
        margin={{top: 10, bottom: 50, left: 50, right: 10}} scale={1} />
    else
      <p>no data</p>


Beers = React.createClass
  mixins: [ReactRouter.Navigation, FluxMixin, StoreWatchMixin("BeerStore")]

  getStateFromFlux: ->
    flux = @getFlux()
    flux.store('BeerStore').getState()

  addbeer: (user) ->
    @getFlux().actions.drinkBeer(user, 1)
    @transitionTo 'home'

  route: (route) ->
    new RegExp(route, 'g').test @context.router.getCurrentPathname()

  render: ->
    if @route('drinking')
      content = <DrinkBeer users={ @state.users } /> 
    else if @route('buying')
      content = <BuyBeer users={ @state.users } /> 
    else if @route('graphs')
      content = <GraphBeer stats={ @state.stats } users={ @state.users } /> 
    
    <div className="beers #{@context.router.getCurrentPathname()}" >
      <ul className="nav nav-tabs" role="tablist">
        <li role="presentation" className={ if @route('drinking') then 'active'  }>
          <a href="#drinking" >Drinking</a>
        </li>
        <li role="presentation" className={ if @route('buying') then 'active' }>
          <a href="#buying">Buying</a>
        </li>
        <li role="presentation" className={ if @route('graphs') then 'active' }>
          <a href="#graphs">Stats</a>
        </li>
        <li role="presentation">
          <a href="#">Overview</a>
        </li>
      </ul>
      { content }
    </div>




# Routes
routes = <ReactRouter.Route>
  <ReactRouter.Route handler={Application} name="home" path="/" />
  <ReactRouter.Route handler={Beers} name="drinking" path="drinking" />
  <ReactRouter.Route handler={Beers} name="buying" path="buying" />
  <ReactRouter.Route handler={Beers} name="graphs" path="graphs" />
</ReactRouter.Route>

$ ->
  ReactRouter.run routes, (Handler) ->
    React.render <Handler flux={flux} />, $("#app")[0]