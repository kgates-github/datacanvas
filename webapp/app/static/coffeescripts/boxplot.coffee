
class BoxPlot extends APP.charts['Chart']

  constructor: (@app, @params, @data, @city, @helpers) ->

    self = @
    @data = _.sortBy(@data, "median")
    @el = @params.el
    @scaleX = @_getScaleX()
    @scaleY = @_getScaleY()
    @qualitative = @params.qualitative or []
    @xAxis = d3.svg.axis().scale(@scaleX).tickSize(-6).tickSubdivide(true)
    
    # Sorting controls
    $("##{@params.dimension}-sort button").on("click", ->
      self._sortBy($(@).val())
      self._toggleButtons($(@).val())
    )

    @svg = d3.select("##{@el}").append("svg")
      .attr("width", @params.width)
      .attr("height", @params.height)

    # X axis
    @svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(#{@params.margin.left}," + (@params.height - 30) + ")")
      .call(@xAxis);

    # Tooltip
    @tip = d3.tip()
      .attr('class', 'd3-tip')
      .offset((d) =>
        [-20, @scaleX(d.median) - @params.margin.left - 18]
      )
      .html((d) ->
        lowerClass = self.helpers.getColorClass(d.lower, self.qualitative)
        lowerName = _.findWhere(self.qualitative, {class: lowerClass}).name
        medianClass = self.helpers.getColorClass(d.median, self.qualitative)
        medianName = _.findWhere(self.qualitative, {class: medianClass}).name
        upperClass = self.helpers.getColorClass(d.upper, self.qualitative)
        upperName = _.findWhere(self.qualitative, {class: upperClass}).name
        html = """
          <div style='font-size:11px; color:#bbb; margin-bottom:0px;'>#{d.name}'s Air Quality Index</div>
          <table class="table borderless">
            <tbody>
              <tr>
                <td>
                  <div>Low</div>
                  <div style="font-size:11px; color:#bbb;">10th<br>percentile</div>
                </td>
                <td style="text-align:center;">
                  <div>Median</div>
                </td>
                <td style="text-align:right;">
                  <div>High</div>
                  <div style="font-size:11px; color:#bbb;">90th<br>percentile</div></td>
              </tr>
              <tr style="font-size:26px;">
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
              </tr>
            </tbody>
          </table>
        """
        html
      )

    @svg.call(@tip)

    @chart = @svg.append("g")
      .attr("transform", "translate(#{@params.margin.left}, #{@params.margin.top})")

    @qualatativeTicks = @chart.selectAll(".qualitative")
      .data(@qualitative)
      .enter()
      .append("g")
      .attr("class", "qualitative")
      .attr("transform", (d, i) =>
        "translate(#{@scaleX(d.value)}, 0)"
      )

    @qualatativeTicks.each((d, i) ->
      y2 = self.params.height - (self.params.margin.top + self.params.margin.bottom) - 4
      d3.select(@)
        .append("line")
        .attr("y1", -24)
        .attr("y2", y2)
        .attr("stroke-dasharray", "3,5")
        .style("stroke-width", 1.5)
        .attr("class", (d) -> d.class)

      d3.select(@)
        .append("text")
        .attr("text-anchor", "end")
        .text((d) -> d.name)
        .attr("x", -6)
        .attr("y", -18)
        .attr("class", (d) -> d.class)
        .style("stroke", "none")
        .style("font-size", "11")
    )

    @chart.append("text")
      .attr("class", "x label")
      .style("fill", "#999")
      .style("font-weight", "400")
      .attr("text-anchor", "end")
      .attr("x", 0)
      .attr("y", @params.height - 49)
      .text("Air quality index")
    
    @chart.selectAll(".plot")
      .data(@data)
      .enter()
      .append("text")
      .text((d, i) -> i + 1)
      .attr("x", -@params.margin.left + 4)
      .attr("y", (d, i) => @scaleY(i) + 6)

    @plots = @chart.selectAll(".plot")
      .data(@data)
      .enter()
      .append("g")
      .attr("class", "plot")
      .attr("transform", (d, i) =>
        "translate(0, #{@scaleY(i)})"
      )

    @plots.each((d, i) ->
      if self.city is d.city
        d3.select(@).append("rect")
          .attr("width", 120)
          .attr("height", 21)
          .attr("x", (d) -> -self.params.margin.left + 20)
          .attr("y", -9)
          .style("fill", "#333")
          .style("stroke", "#333")

      d3.select(@).append("text")
        .text(d.city)
        .attr("x", -self.params.margin.left + 32)
        .attr("y", 6)
        .attr("fill", (d) ->
          if self.city == d.city then "white" else "black"
        )

      d3.select(@).append("rect")
        .attr("width", (d) -> self.scaleX(d.upper) - self.scaleX(d.lower))
        .attr("height", 2)
        .attr("class", "bar")
        .attr("x", (d) -> self.scaleX(d.lower))
        .style("fill", "#777")

      d3.select(@).append("rect")
        .attr("class", (d) -> "lower #{self.helpers.getColorClass(d.lower, self.qualitative)}")
        .attr("height", 15)
        .attr("width", 1)
        .attr("x", (d) -> self.scaleX(d.lower))
        .attr("y", (d, i) -> self.scaleY(i) - 6)

      d3.select(@).append("rect")
        .attr("class", (d) -> "median #{self.helpers.getColorClass(d.median, self.qualitative)}")
        .attr("height", 15)
        .attr("width", 5)
        .attr("x", (d) -> self.scaleX(d.median) - 2)
        .attr("y", (d, i) -> self.scaleY(i) - 6)

      d3.select(@).append("rect")
        .attr("class", (d) -> "upper #{self.helpers.getColorClass(d.upper, self.qualitative)}")
        .attr("height", 15)
        .attr("width", 1)
        .attr("x", (d) -> self.scaleX(d.upper))
        .attr("y", (d, i) -> self.scaleY(i) - 6)

      d3.select(@).append("rect")
        .style("fill", "#none")
        .style("opacity", 0.0)
        .attr("class", "overlay")
        .attr("height", (self.params.height - (self.params.margin.top + self.params.margin.bottom)) / self.data.length)
        .attr("width", self.params.width)
        .attr("x", -self.params.margin.left)
        .attr("y", (d, i) -> self.scaleY(i) - 6)
        .on('mouseover', self.tip.show)
        .on('mouseout', self.tip.hide)
    )

  _toggleButtons: (idx) ->
    d3.selectAll("##{@params.dimension}-sort button").classed({'on': false})
    d3.select("##{idx}").classed({'on': true})

  _getScaleX: ->
    domainX = @_getDomain(@data)
    rangeX = [
        0, @params.width - (@params.margin.left + @params.margin.right)
      ]
    @params.scale()
      .domain(domainX)
      .range(rangeX)

  _getScaleY: ->
    domainY = [0, @data.length]
    rangeY = [
        0, @params.height - (@params.margin.top + @params.margin.bottom)
      ]
    d3.scale.linear()
      .domain(domainY)
      .range(rangeY)

  _sortBy: (dimension='median', delay=0) ->
    @data = _.sortBy(@data, dimension)

    @plots
      .data(@data, (d) -> d.name)
      .transition()
      .delay((d, i) -> (i * 160) + delay)
      .duration(330)
      .ease("linear")
      .attr("transform", (d, i) =>
        "translate(0, #{@scaleY(i)})"
      )

  _getDomain: (data) ->
    max = _.max(_.pluck(data, "upper"))
    min = _.min(_.pluck(data, "lower"))
    [min, max]

  update: (data) ->
    self = @
    @data = data
    @scaleX = @_getScaleX()
    duration = @_getDuration() # Only animate if above the fold
    
    @plots
      .data(@data, (d) -> d.name)

    @plots.each((d, i) ->
      d3.select(@).select(".bar")
        .transition()
        .duration(duration)
        .attr("width", (d) -> self.scaleX(d.upper) - self.scaleX(d.lower))
        .attr("x", (d) -> self.scaleX(d.lower))

      d3.select(@).select(".lower")
        .attr("class", (d) -> "lower #{self.helpers.getColorClass(d.lower, self.qualitative)}")
        .transition()
        .duration(duration)
        .attr("x", (d) -> self.scaleX(d.lower))

      d3.select(@).select(".median")
        .attr("class", (d) -> "median #{self.helpers.getColorClass(d.median, self.qualitative)}")
        .transition()
        .duration(duration)
        .attr("x", (d) -> self.scaleX(d.median))

      d3.select(@).select(".upper")
        .attr("class", (d) -> "upper #{self.helpers.getColorClass(d.upper, self.qualitative)}")
        .transition()
        .duration(duration)
        .attr("x", (d) -> self.scaleX(d.upper))

      d3.select(@).select(".overlay")
        .on('mouseover', self.tip.show)
        .on('mouseout', self.tip.hide)
    )

    @qualatativeTicks.each((d, i) ->
      d3.select(@)
        .transition()
        .duration(duration)
        .attr("transform", (d, i) =>
          "translate(#{self.scaleX(d.value)}, 0)"
        )
    ) 

    @xAxis = d3.svg.axis().scale(@scaleX).tickSize(-6).tickSubdivide(true)
    
    # Update x axis
    @svg.selectAll("g.x.axis")
      .transition()
      .duration(1000)
      .call(@xAxis);

    @_sortBy('median', 1000)  
            
APP.charts['BoxPlot'] = BoxPlot
   