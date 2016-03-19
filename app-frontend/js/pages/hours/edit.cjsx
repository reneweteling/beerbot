# @cjsx React.DOM 
module.exports = React.createClass
  mixins: [backboneModelMixin]
  submitForm: (type='save', e) ->
    self = @
    e.preventDefault()

    # convert the times back
    if @state.model.date.length > 0
      @state.model.start_at = dutchDateToIsoDate @state.model.date, @state.model.start if @state.model.start.length > 0
      @state.model.end_at = dutchDateToIsoDate @state.model.date, @state.model.end if @state.model.end.length > 0

      # add a day, cause we have passed the 24 hour mark
      if @state.model.end.length > 0 and Date.parse(@state.model.start_at) >= Date.parse(@state.model.end_at)
        d = new Date(@state.model.end_at)
        d.setHours d.getHours() + 24
        @state.model.end_at = d.toISOString()

    else
      @state.model.start_at = ''
      @state.model.end_at = ''


    @props.model.save @state.model, 
      success: (a,b,c) ->
        m = self.props.model
        HourCollection.add m
        if type == 'sign'
          Router.navigate "/hours/#{m.uid()}/sign", {trigger: true} 
        else
          Router.navigate "/hours", {trigger: true}
    
    false

  appendInitalState: ->
    {
      model: {
        date:   if @props.model.get('start_at') then dateFormat(@props.model.get('start_at'),'date') else dateFormat(new Date(),'date')
        start:  if @props.model.get('start_at') then dateFormat(@props.model.get('start_at'),'time') else dateFormat(new Date(),'time')
        end:    if @props.model.get('end_at')   then dateFormat(@props.model.get('end_at'),'time')   else ''
      }
    }

  render: ->

    if @state.model['signature_data'] != true
      signBtn = <input type="submit" value="Opslaan & aftekenen" className="btn btn-default pull-right" onClick={@submitForm.bind(@, 'sign')} />

    
    <form> 
      <Select
        {...@setFieldProps('user_id')}
        label="Gebruiker"
        multiple={false} 
        options={UserCollection.selectValues()}
        placeholder= "Zoek op naam"
        />
      
      <bs.Input {...@setFieldProps('date')}  type="date" label="Datum" placeholder="2015-01-01" />
      <bs.Input {...@setFieldProps('start')} type="time" label="Start" placeholder="02:40" />
      <bs.Input {...@setFieldProps('end')}   type="time" label="Eind"  placeholder="05:30" />

      <div className="form-group">
        <input type="submit" value="Opslaan" className="btn btn-primary" onClick={@submitForm.bind(@, 'save')} />
        {signBtn}
      </div>
      
    </form>