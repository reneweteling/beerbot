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

    @setState
      active: user
    

    
  render: ->
    self = @

    buttons = _.map @state.items, (user) ->

      <div className={ if self.state.active == user then 'user active' else 'user'} key={user.id} onClick={self.handleBeer.bind(self, 1, user)} >
        
        <div className="left">
          <button type="button" className="btn btn-default btn-lg">
            <span className="glyphicon glyphicon-eur" aria-hidden="true"></span>
          </button>
        </div>
        
        <div className="center">
          {user.get('first_name')}
        </div>

        <div className="right">
          <button type="button" className="btn btn-default btn-lg">
            <span className="glyphicon glyphicon-glass" aria-hidden="true"></span>
          </button>
        </div>
      </div>
    
    <div className="users">{buttons}</div>


   
