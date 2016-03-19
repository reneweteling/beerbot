module.exports = 
  componentWillMount: ->
    @callback = ( ->
      @setState({ errors: @props.model.validationError })
    ).bind(this)
    @props.model.on("invalid", @callback) 

  componentWillUnmount: ->
    @props.model.off("invalid", @callback)

  getInitialState: ->
    state = { model: {}, erros: {} }
    state = { model: @props.model.attributes, errors: @props.model.validationError } if @props.model?  
    $.extend( true, state, @appendInitalState() ) if @appendInitalState?
    state

  setFieldProps: (props_or_name) ->
    props = {}
    if typeof props_or_name == 'string'
      name = props_or_name
    else
      props = props_or_name
      name = props.name


    _.extend(props, {
      onChange: @changeField.bind(@, name)
      name: name
    })

    props.value ||= @state.model[name] 

    if props.type == 'radio' and @state.model[name]? and "#{props.value}" == "#{@state.model[name]}"
      props.checked = true

    if @state.errors? and @state.errors[name]?
      props.bsStyle = 'error'
      props.help = @state.errors[name].join('. ')
    
    props  

  changeField: (fieldname, event) ->
    setter = "setModel#{fieldname.capitalize()}Attribute"
    attr = {}
    if @[setter]?
      @[setter](fieldname, event)
    else
      if typeof event == 'number' or typeof event == 'string'
        attr[fieldname] = event
      else
        if event.target.type == 'checkbox'
          attr[fieldname] = event.target.checked
        else  
          attr[fieldname] = event.target.value
    
    @setState
      model: _.extend( @state.model, attr )

    @changeFieldAfter(fieldname, event) if @changeFieldAfter
    
  setModel: ->
    @props.model.set @state.model
    
  saveModel: (onSuccess, onError) ->
    @setModel
    if @props.model.isValid()
      @props.model.save()
      onSuccess()
    else
      @state.errors = @props.model.validationError
      @forceUpdate()
      onError()