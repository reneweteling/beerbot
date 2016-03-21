# @cjsx React.DOM 
module.exports = React.createClass
  mixins: [backboneCollectionMixin]

  getInitialState: ->
    items: @props.collection.models
  
  setCollectionState: ->  
    @setState
      items: @props.collection.models
    
  componentDidMount: ->
    @props.collection.fetch
      remove: false
    
  render: ->
    buttons = _.map @state.items, (user) ->
      <div className="user" key={user.id}>
        {user.get('first_name')}
      </div>
    
    <div className="users">{buttons}</div>