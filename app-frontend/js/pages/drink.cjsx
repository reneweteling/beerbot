# @cjsx React.DOM 
module.exports = React.createClass
  mixins: [backboneCollectionMixin]

  getInitialState: ->
    items: @props.collection.models
    active: null
  
  setCollectionState: ->  
    @setState
      items: @props.collection.models
    
  componentDidMount: ->
    @props.collection.fetch
      remove: false

  handleBeer: (amount, user) ->
    self = @

    amount = amount + user.get('transaction') if user.get 'transaction'
    user.set 'transaction', amount

    @setState
      active: user
    AppModel.set 'text', "#{user.to_s()} heeft #{amount} pils gepakt!"
    
    clearTimeout @time if @time
    @time = setTimeout ->
      self.setState
        active: null
      AppModel.unset 'text'
    , 2000
    
  render: ->
    self = @

    buttons = _.map @state.items, (user) ->
      active = self.state.active == user

      <div className={ if active then 'user active' else 'user'} key={user.id} onClick={self.handleBeer.bind(self, 1, user)} >
        <p>{ user.get('first_name') }</p>
      </div>
    
    <div className="content drink-container">{buttons}</div>