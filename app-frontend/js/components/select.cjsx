Select = require 'react-select'
module.exports = React.createClass
  componentDidMount: ->
    
  render: ->
    style = "form-group"
    style = style + " has-#{@props.bsStyle}" if @props.bsStyle?
    <div className={style} >
      <label className="control-label">
        <span >{@props.label}</span>
      </label>
      <br />
      <Select {...@props} />
      <span className="help-block">{@props.help}</span>
    </div>
