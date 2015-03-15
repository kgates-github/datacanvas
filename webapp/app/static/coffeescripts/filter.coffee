
class Filter extends APP.charts['Chart']

  constructor: (@app, @params, @data, @city, @helpers) ->
    self = @
    @dataMonthly = _.findWhere(@data, 
      {
        dimension: @params.dimension, 
        chart: 'monthly'
      }
    )
    @dataTime = _.findWhere(@data, 
      {
        dimension: @params.dimension, 
        chart: 'time_of_day'
      }
    )
    @el = @params.el
    # Get scale for all charts
    combinedData = @dataMonthly.data.concat @dataTime.data
    @scaleX = @_getScaleX(combinedData)
    @monthFormat = d3.time.format("%b")
    
    @dataMonthly =  @dataMonthly.data
    @buttonsMonthly = d3.select("#filter-month-buttons").append("div")
    
    @buttonsMonthly.selectAll("button")
      .data(@dataMonthly)
      .enter()
      .append("div")
      .append("button")
      .attr("type", "button")
      .attr("class", "btn btn-default btn-sm btn-compact")
      .style("width", "65px")
      .style("margin-bottom", "1px")
      .html((d) =>
        @monthFormat(new Date(d.date))
      )

    @chartMonthly = d3.select("#filter-month-chart")
      .append("div")
      .style("width", "112px")

    @barsMonthly = @chartMonthly.selectAll(".bar")
      .data(@dataMonthly)
      .enter()
      .append("div")
      .attr("class", "bar")
      .style("height", "16px")
      .style("background", "#ddd")
      .style("margin-bottom", "5px")
      .style("width", (d) =>
        "#{@scaleX(d.median)}px"
      )

    # Time of day
    @dataTime =  @dataTime.data
    @buttonsTime = d3.select("#filter-time-buttons").append("div")
    
    @buttonsTime.selectAll("button")
      .data(@dataTime)
      .enter()
      .append("div")
      .append("button")
      .attr("type", "button")
      .attr("class", "btn btn-default btn-sm btn-compact")
      .style("width", "65px")
      .style("margin-bottom", "1px")
      .html((d) =>
        d.name
      )

    @chartMonthly = d3.select("#filter-time-chart")
      .append("div")
      .style("width", "112px")

    @barsMonthly = @chartMonthly.selectAll(".bar")
      .data(@dataTime)
      .enter()
      .append("div")
      .attr("class", "bar")
      .style("height", "16px")
      .style("background", "#ddd")
      .style("margin-bottom", "5px")
      .style("width", (d) =>
        "#{@scaleX(d.median)}px"
      )

    
  
  _filterCharts: () ->
    self = @
    # Get new data set here
    # TODO: Set spinners for all the charts
    # TODO: Set filters here
    $.ajax(
      {
        url: "/update/",
        data: {
          'filters': [
            {
              'type': 'month',
              'value': 'February'
            },
            {
              'type': 'time_of_day',
              'value': '5pm to 7pm'
            }
          ]
        }
      }
    ).done( (data) ->
      console.log data

      # Callback to app to update all charts
      self.app.update(data)

    )

  _getScaleX: (data) ->
    domainX = @_getDomain(data)
    rangeX = [
        0, @params.width - (@params.margin.left + @params.margin.right)
      ]

    @params.scale()
      .domain(domainX)
      .range(rangeX)

  _getDomain: (data) ->
    max = _.max(_.pluck(data, "median"))
    #min = _.min(_.pluck(data, "lower"))
    [0, max]

  update: (data) ->
    self = @
    @data = data
    @scaleX = @_getScaleX()
    
    
            
APP.charts['Filter'] = Filter
   