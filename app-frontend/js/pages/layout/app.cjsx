# @cjsx React.DOM 
module.exports = React.createClass
  componentWillMount: ->
    self = @
    @callback = ( ->
      @forceUpdate()
    ).bind(@)
    @props.router.on("route", @callback)
    
  componentWillUnmount: ->
    @props.router.off("route", @callback)

  handleClick: (path, e) ->
    e.preventDefault()
    Router.navigate "/#{path}", {trigger: true} 
  render: ->
    self = @

    links = 
      'drink': 'DRINK!'
      'buy': 'BUY!'
      'stats': 'STATS'
      'index': 'OVERVIEW'

    <div className="flex-vert-container">
      <div className="flex-header">
        <div className="logo">BEER<br/>BOT</div>
        <ul className="navigation">
          {
            if CurrentUser.signedIn()
              _.map links, (label, path) ->
                <li className={ if Backbone.history.getHash()  == path then 'active' } key={path} onClick={self.handleClick.bind(self, path)}>
                  <a href={path}>{label}</a>
                </li>
          }
        </ul>
      </div>
      <div className="flex-body">
        {@props.router.content}
      </div>
    </div>
    