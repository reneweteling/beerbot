# @cjsx React.DOM 
Chart = require('react-google-charts').Chart
         
module.exports = React.createClass
  getInitialState: ->
    items: StatsData
  
  componentDidMount: ->
    self = @
    $.get "#{apiUrl}users/stats", (data) ->
      StatsData = data
      self.setState
        items: StatsData
    
  render: ->
    
    options = 
      orientation: 'horizontal'
      backgroundColor: 'transparent'
      isStacked: true
      bar: 
        groupWidth: '75%'
      chartArea: 
        left: 50
        top: 0
        width: '80%'
        height: '85%'
        

    <div className="content stats-container">
      <Chart chartType="BarChart" width={"100%"} height={"400px"} data={@state.items} options={options} graph_id="chart" />
    </div>