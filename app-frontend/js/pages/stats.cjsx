# @cjsx React.DOM 
BarStackChart = require('react-d3-basic').BarStackChart
d3 = require('d3')

module.exports = React.createClass
  mixins: [backboneCollectionMixin]

  getInitialState: ->
    items: @props.collection.models
    active: null
  
  setCollectionState: ->  
    @setState
      items: @props.collection.models
    
  componentDidMount: ->
    @props.collection.fetch
      remove: false

  handleBeer: (amount, user) ->
    amount = amount + user.get('transaction') if user.get 'transaction'
    user.set 'transaction', amount

    @setState
      active: user
  
    
  render: ->

    # http://www.reactd3.org/docs/basic/#bar_stack

    chartData = [{"name":"Darron Weissnat IV","BMI":20.72,"age":39,"birthday":"2005-01-03T00:00:00.000Z","city":"East Russel","married":false,"index":0},
      {"name":"Pablo Ondricka","BMI":19.32,"age":38,"birthday":"1974-05-13T00:00:00.000Z","city":"Lake Edytheville","married":false,"index":1},
      {"name":"Mr. Stella Kiehn Jr.","BMI":16.8,"age":34,"birthday":"2003-07-25T00:00:00.000Z","city":"Lake Veronicaburgh","married":false,"index":2},
      {"name":"Lavon Hilll I","BMI":20.57,"age":12,"birthday":"1994-10-26T00:00:00.000Z","city":"Annatown","married":true,"index":3},
      {"name":"Clovis Pagac","BMI":24.28,"age":26,"birthday":"1995-11-10T00:00:00.000Z","city":"South Eldredtown","married":false,"index":4},
      {"name":"Gaylord Paucek","BMI":24.41,"age":30,"birthday":"1975-06-12T00:00:00.000Z","city":"Koeppchester","married":true,"index":5},
      {"name":"Ashlynn Kuhn MD","BMI":23.77,"age":32,"birthday":"1985-08-09T00:00:00.000Z","city":"West Josiemouth","married":false,"index":6},
      {"name":"Fern Schmeler IV","BMI":27.33,"age":26,"birthday":"2005-02-10T00:00:00.000Z","city":"West Abigaleside","married":true,"index":7},
      {"name":"Enid Weber","BMI":18.72,"age":17,"birthday":"1998-11-30T00:00:00.000Z","city":"Zackton","married":true,"index":8},
      {"name":"Leatha O'Hara","BMI":17.68,"age":42,"birthday":"2010-10-17T00:00:00.000Z","city":"Lake Matilda","married":false,"index":9},
      {"name":"Korbin Steuber","BMI":16.35,"age":39,"birthday":"1975-06-30T00:00:00.000Z","city":"East Armandofort","married":true,"index":10}]

    chartSeries = [
      {
        field: 'BMI',
        name: 'BMI',
        color: '#ff7f0e'
      }
    ]
    
    x = (d) -> d.index
    yTickFormat = d3.format(".2s")
    <div className="content">
      <BarStackChart
        height={400}
        showXGrid= {false}
        showYGrid= {false}
        title="Users"
        data={chartData}
        chartSeries={chartSeries}
        yTickFormat= {yTickFormat}
        xScale="ordinal"
        x={x}
      />
    </div>


   
