
class Filter extends APP.charts['Chart']

  _getDimensionData: (dimension = 'airquality_raw') ->
    _.where(@data, 
      {
        name: dimension
      }
    )

  constructor: (@app, @params, @data, @city, @helpers) ->
    self = @
    @dimension = 'airquality_raw'
    @workingData = @_getDimensionData(@dimension)
    @dataMonthly = _.findWhere(@workingData, 
      { 
        chart: 'month'
      }
    )
    @dataTime = _.findWhere(@workingData, 
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
      .attr("id", (d) -> "id#{d.time}")
      .attr("value", (d) => @monthFormat(new Date(d.time)))
      .style("width", "65px")
      .style("margin-bottom", "1px")
      .html((d) =>
        @monthFormat(new Date(d.time))
      )
      .on("click", (d) =>
        @_filterCharts(d.time, "btn-monthly")
      )

    @chartMonthly = d3.select("#filter-month-chart")
      .append("div")
      .style("width", "112px")

    @barsMonthly = @chartMonthly.selectAll(".bar")
      .data(@dataMonthly)
      .enter()
      .append("div")
      .attr("class", "bar")
      .style("height", "17px")
      .style("background", "#ddd")
      .style("margin-bottom", "5px")
      .style("width", (d) =>
        "#{@scaleX(d.value)}px"
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
      .attr("id", (d) -> "id#{d.time}")
      .attr("value", (d) -> d.time)
      .style("width", "65px")
      .style("margin-bottom", "1px")
      .html((d) =>
        date = "2015-03-02T#{d.time}"
        st = moment(date)
        et = moment(st).add(2, "hours")
        st.format('h') + '-' + et.format('ha')
      )
      .on("click", (d) =>
        @_filterCharts(d.time+"", "btn-time")
      )

    @chartMonthly = d3.select("#filter-time-chart")
      .append("div")
      .style("width", "112px")

    @barsMonthly = @chartMonthly.selectAll(".bar")
      .data(@dataTime)
      .enter()
      .append("div")
      .attr("class", "bar")
      .style("height", "17px")
      .style("background", "#ddd")
      .style("margin-bottom", "5px")
      .style("width", (d) =>
        "#{@scaleX(d.value)}px"
      )

    d3.select("#reset-filters").on("click", =>
      @_filterCharts(null, null)
    )

  _filterCharts: (filter, btnClass) ->
    $("#spinner").show()
    if filter
      d3.selectAll(".#{btnClass}").classed({'on': false})
      d3.select(".#{btnClass}#id#{filter}").classed({'on': true})

      data = {
        'month': _.pluck(d3.selectAll(".btn-monthly.on")[0], 'value')[0] or null,
        'time_of_day': _.pluck(d3.selectAll(".btn-time.on")[0], 'value')[0] or null,
        'city': @city
      }
    else
      d3.selectAll(".btn-filter").classed({'on': false})
      data = {}

    self = @
   
    $.ajax(
      {
        url: "/update/",
        data: data
      }
    ).done( (data) ->
      $("#spinner").hide()
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
    max = _.max(_.pluck(data, "value"))
    [0, max]

  update: (data) ->
    self = @
    @data = data
    @scaleX = @_getScaleX()
    
    
            
APP.charts['Filter'] = Filter
   