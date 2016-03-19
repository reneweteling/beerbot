# @cjsx React.DOM 
module.exports = React.createClass
  getInitialState: ->
    height: $(window).height() - 170
    search: ""
    projects: @props.collection.models
  mixins: [backboneCollectionMixin]
  
  componentDidMount: ->
    @props.collection.fetch
      remove: false

  setCollectionState: ->
    @setState
      projects: @props.collection.models

  handleProjectClick: (m, e) ->
    CurrentUser.set('project_id', m.id)
    Router.navigate '/', {trigger: true}
    CurrentUser.fetchProjectData()

  handleSearch: (e) ->
    @setState 
      'search': e.target.value,
      projects: _.filter @props.collection.models, (m) ->
        return true if e.target.value.length == 0
        re = new RegExp(e.target.value, 'i')
        re.test m.get('title')

  render: ->
    self = @
  
    content = @state.projects.map (p) ->
      <div className="pointer col-xs-6 col-sm-4" key={p.get('id')} onClick={self.handleProjectClick.bind(self, p)} >
        <div className="panel panel-default">
          <div className="panel-heading">
            <h3 className="panel-title">{p.get('key')}</h3>
          </div>
          <div className="panel-body">{p.get('name')}</div>
        </div>
      </div>

    content = <h3 className="text-center">Er zijn geen projecten gevonden</h3> if @state.projects.length == 0 

    <div>
      <h1>Kies project</h1>
      <bs.Input type="text" placeholder="Zoeken" value={@props.search} onChange={@handleSearch} />
      <div className="row" style={ maxHeight: @state.height, overflowY: 'auto' } >{content}</div>
    </div>