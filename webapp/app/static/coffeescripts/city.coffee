helpers = 
  aqiColorClass: (value) ->
    switch
      when value <= 50 then return 'good' 
      when value <= 100 then return 'moderate'
      when value <= 150 then return 'unhealthy-mild'
      when value <= 200 then return 'unhealthy' 
      when value <= 300 then return 'unhealthy-very' 
      else return 'hazardous'

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
        margin: 
          top: 30
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
