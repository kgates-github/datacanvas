config = 
  charts: [
    {
      type: 'BoxPlot'
      params:
        el: 'ranking-airquality_raw'
        chart: 'ranking'
        dimension: 'airquality_raw'
        scale: d3.scale.linear
        width:700
        height: 250
        margin: 
          top: 30
          right: 50
          bottom: 30
          left: 150
    }
  ]

class App
  constructor: (@config, @data) ->
    @charts = []

    for chart in @config.charts
      data = _.findWhere(@data, 
        {
          dimension: chart.params.dimension, 
          chart: chart.params.chart
        }
      )
      @charts.push new APP.charts[chart.type] @, chart.params, data.data


@app = new App config, data
