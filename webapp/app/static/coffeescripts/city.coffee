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
      },
      {
        name: 'Unhealthy'
        class: 'unhealthy'
        value: 200
      },
      {
        name: 'Very unhealthy'
        class: 'unhealthy-very'
        value: 300
      },
      {
        name: 'Hazardous'
        class: 'hazardous'
        value: 500
      }
    ]

  soundQualitative: [
      {
        name: 'Quiet suburb (50 db)'
        class: 'db50 qualitative-default'
        value: 50
      }
      {
        name: 'Normal conversation (60 db)'
        class: 'db60 qualitative-default'
        value: 60
      }
      {
        name: 'Vacuum cleaner (70 db)'
        class: 'db70 qualitative-default'
        value: 70
      }
      {
        name: 'Freight train (80 db)'
        class: 'db80 qualitative-default'
        value: 80
      }
       {
        name: 'Subway train (90 db)'
        class: 'db90 qualitative-default'
        value: 90
      }
      {
        name: 'Jack hammer (100 db)'
        class: 'db100 qualitative-default'
        value: 100
      }
    ] 

config = 
  charts: [
    {
      type: 'Filter'
      params:
        el: 'filter-container'
        chart: 'filter'
        dimension: 'none'
        scale: d3.scale.linear
        width: 110
        height: 530
        qualitative: helpers.aqiQualitative
        margin: 
          top: 0
          right: 10
          bottom: 10
          left: 5
    }
    {
      type: 'BoxPlot'
      params:
        el: 'ranking-airquality_raw'
        chart: 'ranking'
        dimension: 'airquality_raw'
        name: 'Air quality'
        xAxisLabel: 'Air quality index'
        round: 0
        scale: d3.scale.linear
        width: 700
        height: 290
        qualitative: helpers.aqiQualitative
        margin: 
          top: 40
          right: 50
          bottom: 40
          left: 165
    }
    {
      type: 'AreaChart'
      params:
        el: 'timeseries-airquality_raw'
        chart: 'timeseries'
        dimension: 'airquality_raw'
        name: 'air quality'
        yAxisLabel: 'Air quality index'
        round: 0
        scaleX: d3.time.scale
        scaleY: d3.scale.linear
        width: 700
        height: 430
        qualitative: helpers.aqiQualitative
        margin: 
          top: 10
          right: 0
          bottom: 40
          left: 30
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
      
      if data?
        @charts.push new APP.charts[chart.type] @, chart.params, data.data, city, helpers

  update: (@data) ->
    for chart in @charts
      data = _.findWhere(@data, 
        {
          dimension: chart.params.dimension, 
          chart: chart.params.chart
        }
      )
      chart.update data.data

@app = new App config, data, city, helpers















