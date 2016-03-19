# @cjsx React.DOM 
module.exports = React.createClass
  mixins: [backboneModelMixin]
  getInitialState: ->
    template: null
  
  submitForm: (type='save', e) ->
    self = @
    e.preventDefault()
   
    @props.model.save @state.model, 
      success: (a,b,c) ->
        m = self.props.model
        ChecklistCollection.add m
        Router.navigate "/checklist/#{m.get('templatetype')}", {trigger: true} 
    
    false

  componentDidMount: ->
    self = @

    # brackGetter = (path) ->
    #   parts = path.split('[').map((a) -> a.replace(']',''))
    #   console.log parts
      

    # brackSetter = (path, value, obj) ->
    #   parts = path.split('[').map((a) -> a.replace(']',''))
    #   last = parts.pop()
    #   while(part = parts.shift()) 
    #    obj[part] = {} if typeof obj[part] != "object"
    #    obj = obj[part] # update "pointer"  
    #   obj[last] = value
      

    # rene = {}
    # brackSetter("dit[is][een][test]", "testje", rene)
    # # console.log rene
    # console.log brackGetter('dit[is][een][test]')
    



    ChecklistTemplateCollection.fetch().then (resp) ->

      if self.state.model.checklist_template_id?
        template = ChecklistTemplateCollection.get(self.state.model.checklist_template_id)
      else
        template = ChecklistTemplateCollection.findWhere
          templatetype: self.state.model.templatetype

      attr = {}
      attr['checklist_template_id'] = template.id               unless self.state.model.checklist_template_id?
      attr['user_id'] = CurrentUser.id                          unless self.state.model.user_id?
      attr['project_id'] = CurrentUser.get('project_id')        unless self.state.model.project_id?
      
      attributes = self.state.model
      
      # flatten the model out again.
      if attributes.answers?
        for q_id, answers of attributes.answers
          for answer in answers
            attributes["question[#{q_id}][selected]"] = answer.checklist_question_option_id
            attributes["question[#{q_id}][#{answer.checklist_question_option_id}][answer]"] = answer.answer
      
        delete attributes.answers

      self.setState
        template: template
        model: _.extend( attributes, attr )

  changeFieldAfter: (fieldname, event) ->

    if matches = fieldname.match /question\[(\d+)\]\[selected\]/
      id = parseInt matches[1]

      question = _.findWhere @state.template.attributes.questions, {id: id}
      selected_option = parseInt @state.model["question[#{id}][selected]"]

      if question.allow_multiple == false
        # empty all the answers not related to this option
        unset = {}
        _.each @state.model, (val, attr) ->
          reg = new RegExp "question\\[#{id}\\]\\[(\\d+)\\]\\[answer\\]"
          if match = attr.match reg
            opt_id = match[1]

            if "#{opt_id}" != "#{selected_option}"
              unset[attr] = ''

        @setState
          model: _.extend( @state.model, unset )

      # now lets check if there is an error
      option = _.findWhere question.options, {id: selected_option}
      
      if option and option.alert == true
        showModal('Pas op!', question.alert_message)
          
  handleTextFocus: (q_id, o_id) ->
    key = "question[#{q_id}][selected]"
    
    if @state.model[key] != o_id
      @setState
        model: _.extend( @state.model, {"#{key}" : o_id} )

      # so that the other values are empty'd and alert is triggerd.
      @changeFieldAfter("question[#{q_id}][selected]")

  render: ->
    self = @

    return <p>Template laden</p> unless @state.template and @state.model
    template = @state.template.attributes

    questions = _.map template.questions, (q) ->
      options = _.map q.options, (o) ->

        name = "question[#{q.id}][selected]"
        name_value = "question[#{q.id}][#{o.id}][answer]"
         
        switch o.fieldtype
          when 'answer'
            label = ''
          when 'text' 
            label = <bs.Input {...self.setFieldProps(name_value)} type={'text'} key={"o-#{o.id}-answer"} addonBefore={o.before} addonAfter={o.after} onFocus={self.handleTextFocus.bind(self, q.id, o.id)} />
          when 'textarea'
            label = <bs.Input {...self.setFieldProps(name_value)} type={'textarea'} key={"o-#{o.id}-answer"} addonBefore={o.before} addonAfter={o.after} onFocus={self.handleTextFocus.bind(self, q.id, o.id)} />
          when 'number'
            label = <bs.Input {...self.setFieldProps(name_value)} min="0" max="100" type={'text'} key={"o-#{o.id}-answer"} addonBefore={o.before} addonAfter={o.after} onFocus={self.handleTextFocus.bind(self, q.id, o.id)} />
          else
            label = <p>not implemented {o.fieldtype}</p>

        label = <span>
          {o.title}
          {label}
        </span>

        arg = self.setFieldProps
          name: name
          value: o.id
          label: label
          type: 'radio'

        if q.allow_multiple == true
          arg.type = 'checkbox'

        # add the error text
        if o.alert and arg.checked == true
          arg.bsStyle = 'error'
          arg.help = q.alert_message
        
        <bs.Input {...arg} key={"o-#{o.id}"} />
        

      <div className="question" key={"quesiont-#{q.id}"} >
        <label>{q.title}</label>
        {options}
        <p>{q.footer}</p>
      </div>

    
    <form> 
      <h3>{template.title}</h3>
      <Select
        {...@setFieldProps('user_id')}
        label="Gebruiker"
        multiple={false} 
        options={UserCollection.selectValues()}
        placeholder= "Zoek op naam"
        />
      
      {questions}

      <bs.Input {...@setFieldProps('remarks')}  type="text" label="Opmerkingen" />

      <p>{template.footer}</p>

      <div className="form-group">
        <input type="submit" value="Opslaan" className="btn btn-primary" onClick={@submitForm.bind(@, 'save')} />
      </div>
    </form>