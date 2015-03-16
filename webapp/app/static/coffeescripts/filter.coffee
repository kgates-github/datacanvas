
class Filter extends APP.charts['Chart']

  _getDimensionData: (dimension = 'airquality_raw') ->
    _.findWhere(@data, 
      {
        dimension: dimension
      }
    )

  constructor: (@app, @params, @data, @city, @helpers) ->
    self = @
    @dimension = 'airquality_raw'
    @workingData = @_getDimensionData(@dimension)
    
    @dataMonthly = _.findWhere(@workingData.data, 
      { 
        chart: 'monthly'
      }
    )
    @dataTime = _.findWhere(@workingData.data, 
      {
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
      .attr("class", "btn btn-default btn-sm btn-compact btn-monthly btn-filter")
      .attr("id", (d) -> "id#{d.date}")
      .attr("value", (d) => @monthFormat(new Date(d.date)))
      .style("width", "65px")
      .style("margin-bottom", "1px")
      .html((d) =>
        @monthFormat(new Date(d.date))
      )
      .on("click", (d) =>
        @_filterCharts(d.date, "btn-monthly")
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
      .attr("class", "btn btn-default btn-sm btn-compact btn-time btn-filter")
      .attr("id", (d) -> "id#{d.name}")
      .attr("value", (d) -> d.name)
      .style("width", "65px")
      .style("margin-bottom", "1px")
      .html((d) =>
        d.name
      )
      .on("click", (d) =>
        @_filterCharts(d.name, "btn-time")
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

    d3.select("#reset-filters").on("click", =>
      @_filterCharts(null, null)
    )

  _filterCharts: (filter, btnClass) ->
    if filter
      d3.selectAll(".#{btnClass}").classed({'on': false})
      d3.select("#id#{filter}").classed({'on': true})

      data = [
        {
          'type': 'month',
          'value': _.pluck(d3.selectAll(".btn-monthly.on")[0], 'value')[0] or null
        },
        {
          'type': 'time_of_day',
          'value': _.pluck(d3.selectAll(".btn-time.on")[0], 'value')[0] or null
        }
      ]
      
    else
      d3.selectAll(".btn-filter").classed({'on': false})
      data = []

    console.log data

    self = @
    # Get new data set here
    # TODO: Set spinners for all the charts
    # TODO: Set filters here
    $.ajax(
      {
        url: "/update/",
        data: data
      }
    ).done( (data) ->
      #console.log data

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
   