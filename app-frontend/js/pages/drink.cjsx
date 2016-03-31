# @cjsx React.DOM 
module.exports = React.createClass
  mixins: [backboneCollectionMixin]

  getInitialState: ->
    items: @props.collection.sortByField( 'beer_total', 'desc' ).models
    active: null
  
  setCollectionState: ->  
    @setState
      items: @props.collection.sortByField( 'beer_total', 'desc' ).models
    
  componentDidMount: ->
    @props.collection.fetch
      remove: false

  handleBeer: (amount, user) ->
    self = @

    clearTimeout @time if @time and user == @state.active

    amount = amount + user.get('transaction') if user.get('transaction')?
    user.set 'transaction', amount

    @setState
      active: user
    AppModel.set 'text', "#{user.to_s()} heeft #{amount} pils gepakt!"
    
    @time = setTimeout ->
      amount = user.get 'transaction'
      user.unset 'transaction'



      BeerCollection.create
        creator_id: CurrentUser.id
        user_id: user.id
        amount: amount * -1
      ,
        success: ->
          console.log "fetching"
          self.props.collection.fetch
            remove: false

      self.setState
        active: null
      AppModel.unset 'text'
    , 2000
    
  render: ->
    self = @

    buttons = _.map @state.items, (user) ->
      active = self.state.active == user

      <div className={ if active then 'user active' else 'user'} key={user.id} onClick={self.handleBeer.bind(self, 1, user)} >
        <span className="title">{ user.get('first_name') }</span>
        <span className={"total #{if user.get('beer_total') < 0 then "red"}"}>{ user.get('beer_total') }</span>
        {
          if user.get('transaction')?
            <span className="transaction">{ user.get('transaction') }</span>  
        }
      </div>
    
    <div className="content drink-container">{buttons}</div>