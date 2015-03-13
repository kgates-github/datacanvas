helpers = 
  getColorClass: (value=Infinity, qualitative=[]) ->
    for setting in qualitative
      if value <= setting.value
        return setting.class 

    false

  aqiQualitative: [
      {
        name: 'Good'
        class: 'good'
        value: 50
      },
      {
        name: 'Moderate'
        class: 'moderate'
        value: 100
      },
      {
        name: 'Mildly unhealthy'
        class: 'unhealthy-mild'
        value: 150
      }
    ]

  soundQualitative: [
      {
        name: 'Quiet suburb'
        class: 'moderate'
        value: 50
      },
      {
        name: 'Rock concert'
        class: 'unhealthy-mild'
        value: 100
      }
    ] 

config = 
  charts: [
    {
      type: 'BoxPlot'
      params:
        el: 'ranking-airquality_raw'
        chart: 'ranking'
        dimension: 'airquality_raw'
        scale: d3.scale.linear
        width: 700
        height: 250
        qualitative: helpers.aqiQualitative
        margin: 
          top: 40
          right: 50
          bottom: 30
          left: 165
    }
  ]

class App
  constructor: (@config, @data, city, helpers) ->
    @charts = []

    for chart in @config.charts
      data = _.findWhere(@data, 
        {
          dimension: chart.params.dimension, 
          chart: chart.params.chart
        }
      )
      @charts.push new APP.charts[chart.type] @, chart.params, data.data, city, helpers


@app = new App config, data, city, helpers
