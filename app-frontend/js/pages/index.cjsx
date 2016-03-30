# @cjsx React.DOM 
module.exports = React.createClass
  mixins: [backboneCollectionMixin]

  getInitialState: ->
    items: @props.collection.models
    sort: @props.collection.sort_key
    direction: @props.collection.sort_direction
  
  setCollectionState: ->  
    @setState
      items: @props.collection.sortByField( @state.sort, @state.direction ).models
    
  componentDidMount: ->
    @props.collection.fetch
      remove: false

  setSort: (sort) ->
    direction = if @state.direction == 'asc' then 'desc' else 'asc'
    @setState
      sort: sort
      direction: direction
      items: @props.collection.sortByField( sort, direction ).models

  render: ->
    self = @
    <div className="table-responsive index-container">
      <table className="table table-striped table-condensed">
        <thead>
          <tr>
            {
              _.map {first_name: 'Name', balance: 'Unpaid dues', beer_consumed: 'Consumed', beer_contributed: 'Contributed', beer_total: 'Total'}, (v, k) ->
                <th 
                  key="key-#{k}" 
                  className={"#{self.state.direction} #{if self.state.sort == k then 'active' else '' }"} 
                  onClick={self.setSort.bind(self, k)} >
                  <span className="glyphicon glyphicon-arrow-up" aria-hidden="true"></span>
                  <span className="glyphicon glyphicon-arrow-down" aria-hidden="true"></span>
                  {v}
                </th>
            }
            
          </tr> 
        </thead>
        <tbody>
          {
            _.map @state.items, (user) ->
              <tr key={"user-#{user.id}"}>
                <td>{user.get('first_name')}</td>
                <td>{user.get('balance')}</td>
                <td>{user.get('beer_consumed')}</td>
                <td>{user.get('beer_bought')}</td>
                <td>{user.get('beer_total')}</td>
              </tr>
          }
        </tbody>
      </table>
    </div>