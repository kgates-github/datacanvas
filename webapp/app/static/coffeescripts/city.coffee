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
  constructor: (@config) ->
    @charts = []
    for chart in @config.charts
      @charts.push new APP.charts[chart.type] @, chart.params


@app = new App config
