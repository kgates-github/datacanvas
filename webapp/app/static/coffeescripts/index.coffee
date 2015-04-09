helpers = 
  getColor: (value=Infinity, qualitative=[]) ->
    for setting in qualitative
      if value <= setting.value
        return setting.color 

    false

  aqiQualitative: [
      {
        name: 'Good'
        color: '#33cc33'
        lower: 0
        value: 50
      },
      {
        name: 'Moderate'
        color: '#eebb00'
        lower: 51
        value: 100
      },
      {
        name: 'Mildly unhealthy'
        color: 'rgb(255, 126, 0)'
        lower: 101
        value: 150
      },
      {
        name: 'Unhealthy'
        color: '#cc0000'
        lower: 151
        value: 200
      },
      {
        name: 'Very unhealthy'
        color: 'rgb(153, 0, 76)'
        lower: 201
        value: 300
      },
      {
        name: 'Hazardous'
        color: 'rgb(126, 0, 35)'
        lower: 301
        value: 500
      }
    ]

  

config = 
  charts: [
    {
      type: 'TweenChart'
      params:
        el: 'intro-viz'
        chart: 'circle'
        dimension: 'none'
        scale: d3.scale.linear
        width: 970
        height: 430
        qualitative: helpers.aqiQualitative
        margin: 
          top: 0
          right: 10
          bottom: 10
          left: 5
    }
  ]
###
config = 
  charts: [
    {
      type: 'CircleChart'
      params:
        el: 'intro-viz'
        chart: 'circle'
        dimension: 'none'
        scale: d3.scale.linear
        width: 970
        height: 530
        qualitative: helpers.aqiQualitative
        margin: 
          top: 0
          right: 10
          bottom: 10
          left: 5
    }
  ]
###


class App
  constructor: (@config, @data, helpers) ->
    @charts = []
    @filterChart

    for chart in @config.charts
      @charts.push new APP.charts[chart.type] @, chart.params, @data, helpers
      

  update: (@data) ->
    for chart in @charts
      data = _.findWhere(@data, 
        {
          dimension: chart.params.dimension, 
          chart: chart.params.chart
        }
      )
      chart.update data


@app = new App config, data, helpers















