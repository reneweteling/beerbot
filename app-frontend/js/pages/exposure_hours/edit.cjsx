# @cjsx React.DOM 
module.exports = React.createClass
  mixins: [backboneModelMixin]
  submitForm: (type='save', e) ->
    self = @
    e.preventDefault()

    # convert the times back
    start = Date.parse(@state.model.start_at)
    if @state.model.date.length > 0
      @state.model.start_at = dutchDateToIsoDate @state.model.date, @state.model.start if @state.model.start.length > 0
      @state.model.end_at = dutchDateToIsoDate @state.model.date, @state.model.end if @state.model.end.length > 0

      # add a day, cause we have passed the 24 hour mark
      if @state.model.end.length > 0 
        end = Date.parse(@state.model.end_at)
        if start >= end
          d = new Date(@state.model.end_at)
          d.setHours d.getHours() + 24
          @state.model.end_at = d.toISOString()

    else
      @state.model.start_at = ''
      @state.model.end_at = ''

    @props.model.save @state.model, 
      success: (a,b,c) ->
        ExposureHourCollection.add self.props.model
        Router.navigate "/exposure/user-#{self.props.model.get('user_id')}", {trigger: true} 
      
    
    false

  appendInitalState: ->
    {
      model: {
        date:   if @props.model.get('start_at') then dateFormat(@props.model.get('start_at'),'date') else dateFormat(new Date(),'date')
        start:  if @props.model.get('start_at') then dateFormat(@props.model.get('start_at'),'time') else dateFormat(new Date(),'time')
        end:    if @props.model.get('end_at')   then dateFormat(@props.model.get('end_at'),'time')   else ''
        risk_category: 2 unless @props.model.get('risk_category')
      }
    }

  render: ->

    <form onSubmit={@submitForm.bind(@, 'save')}> 
      <Select
        {...@setFieldProps('user_id')}
        label="Gebruiker"
        multiple={false} 
        options={UserCollection.selectValues()}
        placeholder= 'Zoek op naam'
         />
      <bs.Input {...@setFieldProps('date')}  type="date" label="Datum" placeholder="2015-01-01" />
      <Select
        {...@setFieldProps('risk_category')}
        label="Risicoklasse"
        multiple={false} 
        options={[
          {label: '1', value: '1'},
          {label: '2', value: '2'},
          {label: '3', value: '3'}
        ]}
        placeholder='Risicoklasse'
        />
      <bs.Input {...@setFieldProps('start')} type="time" label="Start" placeholder="02:40" />
      <bs.Input {...@setFieldProps('end')}   type="time" label="Eind"  placeholder="05:30" />

      <div className="form-group">
        <input type="submit" value="Opslaan" className="btn btn-primary" onClick={@submitForm.bind(@, 'save')} />
      </div>
      
    </form>