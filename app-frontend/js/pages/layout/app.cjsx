# @cjsx React.DOM 
module.exports = React.createClass
  componentWillMount: ->
    self = @
    @callback = ( ->
      @forceUpdate()
    ).bind(@)
    @props.router.on "route", @callback
    @props.model.on "all", @callback
    
  componentWillUnmount: ->
    @props.router.off "route", @callback
    $(@props.vars).off "all", @callback

  handleClick: (path, e) ->
    e.preventDefault()
    Router.navigate "/#{path}", {trigger: true} 

  componentWillReceiveProps: (nextProps) ->
    console.log nextProps
    
  render: ->
    self = @

    links = 
      'drink': 'DRINK!'
      'buy': 'BUY!'
      'stats': 'STATS'
      'index': 'OVERVIEW'

    <div className="flex-vert-container">
      <div className="flex-header">
        <div className="logo">
          BEER<br/>BOT
          {
            @props.model.get 'text'
          }
        </div>
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
    