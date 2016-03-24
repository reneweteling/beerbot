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
    amount = amount + user.get('transaction') if user.get 'transaction'
    user.set 'transaction', amount

    AppModel.set 'text', amount

    @setState
      active: user
    

    
  render: ->
    self = @

    buttons = _.map @state.items, (user) ->
      active = self.state.active == user

      <div className={ if active then 'user active' else 'user'} key={user.id} onClick={self.handleBeer.bind(self, 1, user)} >
        <p>{ user.get('first_name') }</p>
        {
          if active
            <p>Pakt {user.get('transaction')} pils</p>
        }

        
      </div>
    
    <div className="content">{buttons}</div>


   
