
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
    @monthFilter = null
    @timeOfDayFilter = null
    
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
      .data(@dataMonthly, (d) -> d.time)
      .enter()
      .append("div")
      .attr("class", "bar")
      .style("height", "17px")
      .style("background", "#ddd")
      .style("margin-bottom", "5px")
      .style("width", (d) =>
        "#{@scaleX(d.value)}px"
      )
      .style("text-align", "right")
      .append("span")
      .attr("class", "bar-text")
      .style("font-size", "11px")
      .style("vertical-align", "top")
      .style("padding-right", "4px")
      .style("color", "#666")
      .html((d) ->
        Math.round(d.value)
      )

    # Time of day
    @dataTime =  _.reject(@dataTime.data, (d) -> 
      parseInt(d.time) % 2 != 0
    )
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

    @chartTime = d3.select("#filter-time-chart")
      .append("div")
      .style("width", "112px")

    @barsTime = @chartTime.selectAll(".bar")

    @barsTime
      .data(@dataTime, (d) -> d.time)
      .enter()
      .append("div")
      .attr("class", "bar")
      .style("height", "17px")
      .style("background", "#ddd")
      .style("margin-bottom", "5px")
      .style("width", (d) =>
        "#{@scaleX(d.value)}px"
      )
      .style("text-align", "right")
      .append("span")
      .attr("class", "bar-text")
      .style("font-size", "11px")
      .style("vertical-align", "top")
      .style("padding-right", "4px")
      .style("color", "#666")
      .html((d) ->
        Math.round(d.value)
      )

    d3.select("#reset-filters").on("click", =>
      @_filterCharts(null, null)
    )

  _filterCharts: (filter, btnClass) ->
    $("#spinner").show()
    if filter
      d3.selectAll(".#{btnClass}").classed({'on': false})
      d3.select(".#{btnClass}#id#{filter}").classed({'on': true})

      @monthFilter = _.pluck(d3.selectAll(".btn-monthly.on")[0], 'value')[0] or null
      @timeOfDayFilter = _.pluck(d3.selectAll(".btn-time.on")[0], 'value')[0] or null

      data = {
        'month': @monthFilter,
        'time_of_day': @timeOfDayFilter,
        'city': @city
      }
    else
      @monthFilter = null
      @timeOfDayFilter = null

      d3.selectAll(".btn-filter").classed({'on': false})
      data = {
        'city': @city
      }

    self = @
   
    $.ajax(
      {
        url: "/update/",
        data: data
      }
    ).done( (data) ->
      $("#spinner").hide()
      # Callback to app to update all charts
      self.app.update(data.data)
    )

  _getScaleX: (data) ->
    domainX = @_getDomain(data)
    rangeX = [
        0, @params.width - (@params.margin.left + @params.margin.right + 10)
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
    
    @workingData = @_getDimensionData(@dimension)
    @newDataMonthly = _.findWhere(@workingData, 
      { 
        chart: 'month'
      }
    )
    @newDataTime = _.findWhere(@workingData, 
      {
        chart: 'time_of_day'
      }
    )

    # Get scale for all charts
    combinedData = @newDataMonthly.data.concat @newDataTime.data
    @scaleX = @_getScaleX(combinedData)
   
    #console.log @newDataMonthly.data.length

    if @newDataMonthly.data.length == 1
      @newDataMonthly = @newDataMonthly.data[0]

      for i of @dataMonthly
        if @dataMonthly[i].time == @newDataMonthly.time
          @dataMonthly[i].value = @newDataMonthly.value
        else
          @dataMonthly[i].value = 0
    else
      @dataMonthly = @newDataMonthly.data

    
    if @newDataTime.data.length == 2
      @newDataTime = @newDataTime.data[0]

      for i of @dataTime
        if @dataTime[i].time == @newDataTime.time
          @dataTime[i].value = @newDataTime.value
        else
          @dataTime[i].value = 0
    else
      @dataTime = @newDataTime.data
    
    @chartMonthly.selectAll(".bar")
      .data(@dataMonthly, (d) -> d.time)
      .transition()
      .duration(1000)
      .style("width", (d) =>
        #console.log d
        "#{@scaleX(d.value)}px"
      )

    @chartMonthly.selectAll(".bar").each((d, i) ->
      d3.select(@).select(".bar-text")
      .html(() ->
        if d.value == 0 
          return ""
        Math.round(d.value)
      )
    )

    @chartTime.selectAll(".bar")
      .data(@dataTime, (d) -> d.time)
      .transition()
      .duration(1000)
      .style("width", (d) =>
        #console.log d
        "#{@scaleX(d.value)}px"
      )

    @chartTime.selectAll(".bar").each((d, i) ->
      d3.select(@).select(".bar-text")
      .html(() ->
        if d.value == 0 
          return ""
        Math.round(d.value)
      )
    )
    

  getFilters: () ->
    startMonth = @monthFormat(new Date(@dataMonthly[0].time))
    endMonth = @monthFormat(new Date(@dataMonthly[@dataMonthly.length-1].time))

    if @timeOfDayFilter
      date = "2015-03-02T#{@timeOfDayFilter}"
      st = moment(date)
      et = moment(st).add(2, "hours")
      timeOfDayFilter = st.format('h') + ' and ' + et.format('ha')
    else
      timeOfDayFilter = null

    return {
      'monthFilter': @monthFilter
      'timeOfDayFilter': timeOfDayFilter
      'startMonth': startMonth
      'endMonth': endMonth
    }
    
            
APP.charts['Filter'] = Filter
   