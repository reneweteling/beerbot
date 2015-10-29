# Constants (Action types)
constants =
  DRINK_BEER: 'DRINK_BEER'
  BUY_BEER: 'BUY_BEER'

# Stores
BeerStore = Fluxxor.createStore
  initialize: ->
    @users = {}
    @getFromApi()
    @bindActions(constants.DRINK_BEER, @drinkBeer,
                 constants.BUY_BEER,   @drinkBeer)
    
  getFromApi: ->
    self = @
    $.getJSON "/beers", (data) -> 
      self.updateUsers data

  updateUsers: (users) ->
    for u in users
      @users[u.id] = u
    @emit 'change'

  drinkBeer: (payload, type) ->
    window.audio_beer.load()
    window.audio_beer.play()
    payload.amount = payload.amount * -1 if type == constants.BUY_BEER
    self = @
    $.post "/beers", { beer: {user_id: payload.user.id, amount: payload.amount} }, (data) ->
      self.updateUsers data      
    , "json"
  
  getState: -> users: @users

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
    @transitionTo 'beers'

  render: ->
    users = @state.users
    <table className="table table-striped" onClick={this.handleClick}>
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
  
Beers = React.createClass
  mixins: [ReactRouter.Navigation, FluxMixin, StoreWatchMixin("BeerStore")]

  getStateFromFlux: ->
    flux = @getFlux()
    flux.store('BeerStore').getState()

  drinkBeer: (user) ->
    @getFlux().actions.drinkBeer(user, 1)
    @.transitionTo 'home'

  render: ->
    self = @
    users = @state.users
    <div className="beers">
      <h1 className="text-center">Drink some beer!!</h1>
      {
        Object.keys(users).map (i) ->
          user = users[i]
          <button className="btn btn-info btn-lg" key={i} type="submit" onClick={self.drinkBeer.bind(self, user)}  >{user.first_name}</button>
      }
    </div>

# Routes
routes = <ReactRouter.Route>
  <ReactRouter.Route handler={Application} name="home" path="/" />
  <ReactRouter.Route handler={Beers} name="beers" path="beers" />
</ReactRouter.Route>

$ ->
  ReactRouter.run routes, (Handler) ->
    React.render <Handler flux={flux} />, $("#app")[0]