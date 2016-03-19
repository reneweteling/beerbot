module.exports = React.createClass
  getInitialState: ->
    open: false
    show: false
    
  show: ->
    self = @

    self.setState
      open: true
    
    setTimeout ->
      self.setState
        show: true
    , 50
    
  hide: ->
    self = @

    self.setState
      show: false

    setTimeout ->
      self.setState
        open: false
    , 500

  handleClick: (path) ->
    @hide()
    Router.navigate path, {trigger: true}

  componentWillReceiveProps: (nextProps) ->
    
    if @state.open != nextProps.open
      if nextProps.open == true
        @show()
      else
        @hide()

  render: ->
    self = @

    buttons = _.map @props.buttons, (action, label) ->
      <button type="button" className="btn btn-primary" key={"goto-#{action}"} onClick={self.handleClick.bind(self, action)}>{label}</button>
    

    <div className={ if @state.show then 'modal fade in' else 'modal fade '} style={if @state.open then { display : 'block' } else { display: 'none' }} tabIndex="-1" role="dialog" >
      <div className="modal-dialog" role="document">
        <div className="modal-content">
          <div className="modal-header">
            <button type="button" className="close" data-dismiss="modal" aria-label="Close" onClick={hideModal}><span aria-hidden="true">&times;</span></button>
            <h4 className="modal-title" >{ @props.title }</h4>
          </div>
          <div className="modal-body">
            { @props.body }
          </div>
          <div className="modal-footer">
            <button type="button" className="btn btn-default" data-dismiss="modal" onClick={hideModal}>Sluit</button>
            {buttons}
          </div>
        </div>
      </div>
    </div>