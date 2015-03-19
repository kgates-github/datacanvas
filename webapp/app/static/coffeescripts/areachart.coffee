
class AreaChart extends APP.charts['Chart']

  constructor: (@app, @params, @data, @city, @helpers) ->
    self = @
    @el = @params.el
    @scaleX = @_getScaleX()
    @scaleY = @_getScaleY() 
    @qualitative = @params.qualitative or []
    @xAxis = d3.svg.axis().scale(@scaleX).innerTickSize(6).orient("top")
    @yAxis = d3.svg.axis().scale(@scaleY).orient("left")

    @svg = d3.select("##{@el}").append("svg")
      .attr("width", @params.width)
      .attr("height", @params.height)

    # Tooltip
    @tip = d3.tip()
      .attr('class', 'd3-tip')
      .offset((d) =>
        #@scaleY(d.max) - 
        [-20, -(@params.width-@params.margin.left) / @data.length / 2]
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
          <div style='margin-bottom:10px; font-size:11px; color:#bbb;'>#{@city}'s #{@params.name}</div>
          <div style='margin-top:12px; color:white; font-size:20px; font-weight: 400;'>
            #{moment(d.date).format('MMM D, YYYY')}
          </div>
         <hr style="margin-bottom:2px; opacity:0.3;">
          <table class="table borderless">
            <tbody>
              <tr>
                <td style="text-align:center;">
                  <div>Min</div>
                </td>
                <td style="text-align:center;">
                  <div>Low</div>
                  <div style="font-size:11px; color:#bbb;">10th<br>percentile</div>
                </td>
                <td style="text-align:center;">
                  <div>Median</div>
                  <div style="font-size:11px; color:#bbb;">50th<br>percentile</div>
                </td>
                <td style="text-align:center;">
                  <div>High</div>
                  <div style="font-size:11px; color:#bbb;">90th<br>percentile</div>
                </td>
                <td style="text-align:center;">
                  <div>Max</div>
                </td>
              </tr>
              <tr style="font-size:26px;">
                <td class="#{minClass}" style="width:70px; color:white; text-align:center;">
                  #{d3.round(d.min, self.params.round)}
                  <div style="font-size:11px; color:#fff;">#{minName}</div></td>
                </td>
                <td class="#{lowerClass}" style="width:70px; color:white; text-align:center;">
                  #{d3.round(d.lower, self.params.round)}
                  <div style="font-size:11px; color:#fff;">#{lowerName}</div></td>
                </td>
                <td class="#{medianClass}" style="width:70px; color:white; text-align:center;">
                  #{d3.round(d.median, self.params.round)}
                  <div style="font-size:11px; color:#fff;">#{medianName}</div></td>
                </td>
                <td class="#{upperClass}" style="width:70px; color:white; text-align:center;">
                  #{d3.round(d.upper, self.params.round)}
                  <div style="font-size:11px; color:#fff;">#{upperName}</div></td>
                </td>
                <td class="#{maxClass}" style="width:70px; color:white; text-align:center;">
                  #{d3.round(d.max, self.params.round)}
                  <div style="font-size:11px; color:#fff;">#{maxName}</div></td>
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
  
    @areaMax = d3.svg.area()
      .x((d) => @scaleX(new Date(d.date)))
      .y0((d) =>  @scaleY(d.min))
      .y1((d) => @scaleY(d.max))

    @areaMaxPlot = @chart.append("path")
      .datum(@data)
      .attr("class", "area")
      .style("fill", "#eee")
      .attr("d", @areaMax)

    @areaPercentile = d3.svg.area()
      .x((d) => @scaleX(new Date(d.date)))
      .y0((d) =>  @scaleY(d.lower))
      .y1((d) => @scaleY(d.upper))

    @areaPercentilePlot = @chart.append("path")
      .datum(@data)
      .attr("class", "area")
      .style("fill", "#ccc")
      .attr("d", @areaPercentile)

    @line = d3.svg.line()
      .x((d) => @scaleX(new Date(d.date)))
      .y((d) => @scaleY(d.median))

    @areaMedianPlot = @chart.append("path")
      .datum(@data)
      .attr("class", "line")
      .attr("d", @line)

    #<image xlink:href="firefox.jpg" x="0" y="0" height="50px" width="50px"/>
    @key = @svg
      .append("g")
      .attr("id", "area-key")
      .attr("transform", "translate(#{@params.margin.left + 50}, #{@params.margin.top})")

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
      .data(@data)
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


  _getDomain: (data) ->
    max = _.max(_.pluck(data, "max"))
    min = _.min(_.pluck(data, "min"))
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
      .datum(@data)
      .transition()
      .duration(duration)
      .attr("d", @areaMax)

    @areaPercentilePlot
      .datum(@data)
      .transition()
      .duration(duration)
      .attr("d", @areaPercentile)

    @areaMedianPlot
      .datum(@data)
      .transition()
      .duration(duration)
      .attr("d", @line)

    # Update x axis
    @svg.selectAll("g.x.axis")
      .transition()
      .duration(duration)
      .call(@xAxis)

    @svg.selectAll("g.y.axis")
      .transition()
      .duration(duration)
      .call(@yAxis);


APP.charts['AreaChart'] = AreaChart
   