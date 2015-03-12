config = 
  charts: [
    {
      type: 'BoxPlot'
      params:
        el: 'ranking-airquality_raw'
        chart: 'ranking'
        dimension: 'airquality_raw'
        width:700
        height: 400
        margin: 10
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
