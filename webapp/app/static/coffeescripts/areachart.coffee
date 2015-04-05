
class AreaChart extends APP.charts['Chart']

  constructor: (@app, @params, @data, @city, @helpers) ->
    self = @
    @el = @params.el
    @qualitative = @params.qualitative or []
    @scaleX = @_getScaleX()
    @scaleY = @_getScaleY() 
    @xAxis = d3.svg.axis().scale(@scaleX).innerTickSize(6).orient("top")
    @yAxis = d3.svg.axis().scale(@scaleY).orient("left")

    @svg = d3.select("##{@el}").append("svg")
      .attr("width", @params.width)
      .attr("height", @params.height)

    # Tooltip
    @tip = d3.tip()
      .attr('class', 'd3-tip')
      .direction('w')
      .offset((d) =>
        #@scaleY(d.max) - 
        [-(@params.width-@params.margin.left) / @data.length / 2, -20]
      )
      .html((d) =>  
        minClass = self.helpers.getColorClass(d.min, self.qualitative)
        minName = _.findWhere(self.qualitative, {class: minClass}).name
        lowerClass = self.helpers.getColorClass(d.lower, self.qualitative)
        lowerName = _.findWhere(self.qualitative, {class: lowerClass}).name
        medianClass = self.helpers.getColorClass(d.median, self.qualitative)
        medianName = _.findWhere(self.qualitative, {class: medianClass}).name
        upperClass = self.helpers.getColorClass(d.upper, self.qualitative)
        upperName = _.findWhere(self.qualitative, {class: upperClass}).name
        maxClass = self.helpers.getColorClass(d.max, self.qualitative)
        maxName = _.findWhere(self.qualitative, {class: maxClass}).name
        html = """
          <div style='text-align:center; margin-bottom:10px; font-size:11px; color:#bbb;'>Air quality index scores</div>
          <div style='text-align:center; margin-top:12px; margin-bottom:10px; color:white; font-size:20px; font-weight: 400;'>
            #{moment(d.date).format('MMM D, YYYY')}
          </div>
         <hr>
          <table class="table borderless">
            <tbody>
              <tr>
                <td style="text-align:right; vertical-align:center;">
                  <div>Max</div>
                </td>
                <td class="#{maxClass}-score" style="font-size:26px; line-height:26px; width:70px; text-align:center;">
                  #{d3.round(d.max, self.params.round)}
                  <div style="font-size:11px;">#{maxName}</div></td>
                </td>
              </tr>
              <tr>
                <td style="text-align:right;">
                  <div>High</div>
                  <div style="font-size:11px; color:#bbb;">75th<br>percentile</div>
                </td>
                <td class="#{upperClass}-score" style="font-size:26px; line-height:26px; width:70px; text-align:center;">
                  #{d3.round(d.upper, self.params.round)}
                  <div style="font-size:11px;">#{upperName}</div></td>
                </td>
              </tr>
              <tr>
                <td style="text-align:right;">
                  <div>Average</div>
                  
                </td>
                <td class="#{medianClass}-score" style="font-size:26px; line-height:26px; width:70px; text-align:center;">
                  #{d3.round(d.median, self.params.round)}
                  <div style="font-size:11px;">#{medianName}</div></td>
                </td>
              </tr>
              <tr>
                <td style="text-align:right;">
                  <div>Low</div>
                  <div style="font-size:11px; color:#bbb;">25th<br>percentile</div>
                </td>
                 <td class="#{lowerClass}-score" style="font-size:26px; line-height:26px; width:70px; text-align:center;">
                  #{d3.round(d.lower, self.params.round)}
                  <div style="font-size:11px;">#{lowerName}</div></td>
                </td>
              </tr>
              <tr>
                <td style="text-align:right;">
                  <div>Min</div>
                </td>
                <td class="#{minClass}-score" style="font-size:26px; line-height:26px; width:70px; text-align:center;">
                  #{d3.round(d.min, self.params.round)}
                  <div style="font-size:11px;">#{minName}</div></td>
                </td>
              </tr>
            </tbody>
          </table>
        """
        html
      )

    @svg.call(@tip)

    # X axis
    @svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(20, #{@params.margin.top - 10})")
      .call(@xAxis)

    @svg.append("g")
      .attr("class", "y axis")
      .attr("transform", "translate(#{@params.margin.left - 1}, #{@params.margin.top})")
      .call(@yAxis)
    .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", "0.8em")
      .style("text-anchor", "end")
      .style("font-size", "11px")
      .text(@params.yAxisLabel)

    @chart = @svg.append("g")
      .attr("transform", "translate(#{@params.margin.left}, #{@params.margin.top})")
    
    @qualatativeTicks = @chart.selectAll(".qualitative")
      .data(@qualitative)
      .enter()
      .append("g")
      .attr("class", "qualitative")
      .attr("transform", (d, i) =>
        "translate(0, #{@scaleY(d.value)})"
      )

    @qualatativeTicks.each((d, i) ->
      x2 = self.params.width - self.params.margin.left
      d3.select(@)
        .append("line")
        .attr("x1", self.params.margin.left)
        .attr("x2", x2)
        .attr("stroke-dasharray", "3,5")
        .style("stroke-width", 2.5)
        .attr("class", (d) -> d.class)
      
      #console.log self.scaleY(50), self.scaleY(150), self.scaleY(250), self.scaleY(450)
      ###
      d3.select(@)
        .append("line")
        .attr("x1", self.params.width - self.params.margin.left - 2.5 - 10)
        .attr("x2", self.params.width - self.params.margin.left - 2.5 - 10)
        .attr("y1", self.scaleY(50))
        .attr("y2", 0)
        .style("stroke-width", 5.0)
        .attr("class", (d) -> d.class)
      ###

      d3.select(@)
        .append("text")
        .text((d) -> d.name)
        .attr("text-anchor", "end")
        .attr("transform", "translate(#{self.params.width - self.params.margin.right - 10}, 10) rotate(-90)")
        .attr("class", (d) -> d.class)
        .style("stroke", "none")
        .style("font-size", "11")
      
    )

    @areaMax = d3.svg.area()
      .x((d) => @scaleX(new Date(d.date)))
      .y0((d) =>  @scaleY(d.min))
      .y1((d) => @scaleY(d.max))

    @areaMaxPlot = @chart.append("path")
      .datum(@data, (d) -> d.date)
      .attr("class", "area")
      .style("fill", "#eee")
      .attr("d", @areaMax)

    @areaPercentile = d3.svg.area()
      .x((d) => @scaleX(new Date(d.date)))
      .y0((d) =>  @scaleY(d.lower))
      .y1((d) => @scaleY(d.upper))

    @areaPercentilePlot = @chart.append("path")
      .datum(@data, (d) -> d.date)
      .attr("class", "area")
      .style("fill", "#ccc")
      .attr("d", @areaPercentile)

    @line = d3.svg.line()
      .x((d) => @scaleX(new Date(d.date)))
      .y((d) => @scaleY(d.median))

    @areaMedianPlot = @chart.append("path")
      .datum(@data, (d) -> d.date)
      .attr("class", "line")
      .attr("d", @line)

    #<image xlink:href="firefox.jpg" x="0" y="0" height="50px" width="50px"/>
    @key = @svg
      .append("g")
      .attr("id", "area-key")
      .style("display", "none")
      .attr("transform", "translate(#{@params.width - 140}, #{@params.margin.top})")

    @key
      .append("rect")
      .attr("width", 135)
      .attr("height", 140)
      .style("stroke", "#ddd")
      .style("fill", "#fff")

    @key
      .append("image")
      .attr("xlink:href", area_key)
      .attr("width", 119)
      .attr("height", 136)
      .attr("x", 10)
      .attr("y", 2)
      .on("click", =>
        @key.style("opacity", 0) 
      )

    @chart.selectAll(".overlay")
      .data(@data, (d) -> d.date)
      .enter()
      .append("rect")
      .style("fill", "#333")
      .style("opacity", 0.0)
      .attr("class", "overlay")
      .attr("height", @params.height - (@params.margin.top + @params.margin.bottom))
      .attr("width", @params.width / @data.length)
      .attr("x", (d) => @scaleX(new Date(d.date)))
      .attr("y", 0)
      .on('mouseover', @tip.show)
      .on('mouseout', @tip.hide)

    @_setExplanationText()

  _getDomain: (data) ->
    max = _.max(_.pluck(data, "max"))
    min = _.min(_.pluck(data, "min"))
    
    if @qualitative.length
      for elem in @qualitative
        if max < elem.value
          max = elem.value
          break
    if max < 55
      max = 55
    
    [min, max]

  _getScaleX: ->
    domainX = d3.extent(@data, (d) -> d.date)
    rangeX = [
        0, @params.width - (@params.margin.left + @params.margin.right)
      ]

    d3.time.scale()
      .range(rangeX)
      .domain([new Date(domainX[0]), new Date(domainX[1])])
    
  _getScaleY: ->
    domainY = @_getDomain(@data)
    rangeY = [
        @params.height - (@params.margin.top + @params.margin.bottom), 0
      ]

    @params.scaleY()
      .domain(domainY)
      .range(rangeY)
  
  update: (data) ->
    duration = 0 #@_getDuration() # Only animate if above the fold

    @data = data
    #console.log @data

    @scaleX = @_getScaleX()
    @scaleY = @_getScaleY() 
    @xAxis = d3.svg.axis().scale(@scaleX).tickSize(-6).orient("top")
    @yAxis = d3.svg.axis().scale(@scaleY).orient("left")

    # Recalculate areas
    @areaMax = d3.svg.area()
      .x((d) => @scaleX(new Date(d.date)))
      .y0((d) =>  @scaleY(d.min))
      .y1((d) => @scaleY(d.max))

    @areaPercentile = d3.svg.area()
      .x((d) => @scaleX(new Date(d.date)))
      .y0((d) =>  @scaleY(d.lower))
      .y1((d) => @scaleY(d.upper))

    @line = d3.svg.line()
      .x((d) => @scaleX(new Date(d.date)))
      .y((d) => @scaleY(d.median))

    @areaMaxPlot
      .datum(@data, (d) -> d.date)
      .transition()
      .duration(duration)
      .attr("d", @areaMax)

    @areaPercentilePlot
      .datum(@data, (d) -> d.date)
      .transition()
      .duration(duration)
      .attr("d", @areaPercentile)

    @areaMedianPlot
      .datum(@data, (d) -> d.date)
      .transition()
      .duration(duration)
      .attr("d", @line)

    @chart.selectAll(".overlay").remove()

    @chart.selectAll(".overlay")
      .data(@data, (d) -> d.date)
      .enter()
      .append("rect")
      .style("fill", "#333")
      .style("opacity", 0.0)
      .attr("class", "overlay")
      .attr("height", @params.height - (@params.margin.top + @params.margin.bottom))
      .attr("width", @params.width / @data.length)
      .attr("x", (d) => @scaleX(new Date(d.date)))
      .attr("y", 0)
      .on('mouseover', @tip.show)
      .on('mouseout', @tip.hide)
     

    # Update x axis
    @svg.selectAll("g.x.axis")
      .transition()
      .duration(duration)
      .call(@xAxis)

    @svg.selectAll("g.y.axis")
      .transition()
      .duration(duration)
      .call(@yAxis)

    @_setExplanationText()

  _setExplanationText: ->
    @filters = @app.getFilters()
    monthText = if @filters.monthFilter then " from #{@filters.monthFilter}, 2015" else \
      " between #{@filters.startMonth} and #{@filters.endMonth}, 2015"

    timeOfDayText = if @filters.timeOfDayFilter? then \
      " only using data collected between #{@filters.timeOfDayFilter}" else ""

    html = "Air quality index scores #{monthText}#{timeOfDayText}."
    d3.select("#timeseries-explanation").html(html)

    

APP.charts['AreaChart'] = AreaChart
   