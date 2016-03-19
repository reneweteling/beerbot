# @cjsx React.DOM 
SignaturePad = require 'react-signature-pad' 

module.exports = React.createClass
  mixins: [backboneModelMixin]

  handleCancel: (e) ->
    e.preventDefault()
    Router.navigate "/hours", {trigger: true}
    false

  submitForm: (e) ->
    self = @
    e.preventDefault()
    
    @state.model['signature_data'] = @refs.sig.toDataURL()
    @props.model.save @state.model
    Router.navigate "/hours", {trigger: true}

    false

  render: ->
    self = @

    <form onSubmit={@submitForm}> 
      <p>Met het zetten van mijn handtekening verklaar ik dat ik de werkzaamheden conform het werkplan heb uitgevoerd en dat ik de juiste persoonlijke beschermingsmiddelen heb gedragen alsmede dat ik in het bezit ben van een geldig DAV en/of DTA certificaat, een medische geschiktheidsverklaring, de campagne Vezelveiligheid heb gevolgd en een Fit-test certificaat heb en het juiste volgelaatsmasker draag. </p>
      <p>Tevens tekenen ik hiermee voor de registratie van mijn blootstellingsuren. </p>
      <p>De registratie/ondertekening van de instructie vind plaats via het kick-off / toolbox formulier.</p>
      
      <div className="form-group signature-wrapper">
        <label className="control-label">
          <span>Handtekening</span>
        </label>
        <SignaturePad ref="sig" />
      </div>

      <div className="form-group">
        <input type="submit" value="Onderteken" className="btn btn-primary" onClick={@submitForm} />
        <input type="submit" value="Annuleer" className="btn btn-default pull-right" onClick={@handleCancel} />
      </div>

    </form>