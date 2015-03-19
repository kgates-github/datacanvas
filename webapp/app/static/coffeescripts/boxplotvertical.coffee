
class BoxPlotVertical extends APP.charts['Chart']

  constructor: (@app, @params, @data, @city, @helpers) ->
    self = @
    @data = _.sortBy(@data, "median")
    @el = @params.el
    @scaleX = @_getScaleX()
    @scaleY = @_getScaleY()
    @qualitative = @params.qualitative or []
    @xAxis = d3.svg.axis().scale(@scaleX).tickSize(-6).tickSubdivide(true)
    @yAxis = d3.svg.axis().scale(@scaleY).orient("left").ticks(3)
    
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
      .attr("transform", "translate(#{@params.margin.left}," + (@params.height - 16) + ")")
      .call(@xAxis);

    @svg.append("g")
      .attr("class", "y axis")
      .attr("transform", "translate(#{@params.margin.left - 1}, #{@params.margin.top + 8})")
      .call(@yAxis)
    
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
          <div style='font-size:11px; color:#bbb; margin-bottom:0px;'>#{d.city}'s Air Quality Index</div>
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
      .attr("transform", "translate(#{@params.margin.left + 2}, #{@params.margin.top + 8})")


    @plots = @chart.selectAll(".plot")
      .data(@data)
      .enter()
      .append("g")
      .attr("class", "plot")
      .attr("transform", (d, i) =>
        "translate(#{@scaleX(new Date(d.date))}, 0)"
      )

    @plots.each((d, i) ->
      
      d3.select(@).append("rect")
        .attr("width", (self.params.width - self.params.margin.left - self.params.margin.right) / self.data.length - 2)
        .attr("height", (d) ->
          #console.log self.scaleY(d.max), self.scaleY(d.min), d.max, d.min
          self.scaleY(d.min) - self.scaleY(d.max) + 2
        )
        .attr("x", 0)
        .attr("y", (d) ->
          self.params.height - self.scaleY(d.min) - self.params.margin.top - self.params.margin.bottom
        )
        .attr("class", "bar")
        .style("fill", "#ddd")

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

    @svg.append("text")
      .attr("class", "x label")
      .style("fill", "#999")
      .style("font-weight", "400")
      .attr("text-anchor", "start")
      .attr("x", @params.margin.left + 6)
      .attr("y", 10)
      .text(@params.yAxisLabel)

  _toggleButtons: (idx) ->
    d3.selectAll("##{@params.dimension}-sort button").classed({'on': false})
    d3.select("##{idx}").classed({'on': true})

  _getScaleX: ->
    domainX = d3.extent(@data, (d) -> d.date)
    rangeX = [
        0, @params.width - (@params.margin.left + @params.margin.right)
      ]

    d3.time.scale()
      .range(rangeX)
      .domain([new Date(domainX[0]), new Date(domainX[1])])

  _getDomain: (data) ->
    max = _.max(_.pluck(data, "max"))
    min = _.min(_.pluck(data, "min"))
    [min, max]

  _getScaleY: ->
    domainY = @_getDomain(@data)
    rangeY = [
        (@params.height - @params.margin.top - @params.margin.bottom - 10), 0
      ]

    #console.log domainY
    #console.log rangeY

    @params.scaleY()
      .domain(domainY)
      .range(rangeY)

  _sortBy: (dimension='median', delay=0) ->
    @data = _.sortBy(@data, dimension)
    
    @plots
      .data(@data, (d) -> d.city)
      .transition()
      .delay((d, i) -> (i * 160) + delay)
      .duration(330)
      .ease("linear")
      .attr("transform", (d, i) =>
        "translate(0, #{@scaleY(i)})"
      )

  update: (data) ->
    self = @
    @data = data
    @scaleX = @_getScaleX()
    @scaleY = @_getScaleY()
    duration = 0 #@_getDuration() # Only animate if above the fold

    @plots.remove()
    
    @plots = @chart.selectAll(".plot")
      .data(@data)
      .enter()
      .append("g")
      .attr("class", "plot")
      .attr("transform", (d, i) =>
        "translate(#{@scaleX(new Date(d.date))}, 0)"
      )

    @plots.each((d, i) ->
      
      d3.select(@).append("rect")
        .attr("width", (self.params.width - self.params.margin.left - self.params.margin.right) / self.data.length - 2)
        .attr("height", (d) ->
          #console.log self.scaleY(d.max), self.scaleY(d.min), d.max, d.min
          self.scaleY(d.min) - self.scaleY(d.max) + 2
        )
        .attr("x", 0)
        .attr("y", (d) ->
          self.params.height - self.scaleY(d.min) - self.params.margin.top - self.params.margin.bottom
        )
        .attr("class", "bar")
        .style("fill", "#ddd")

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
    
    @xAxis = d3.svg.axis().scale(@scaleX).tickSize(-6).tickSubdivide(true)
    
    # Update x axis
    @svg.selectAll("g.x.axis")
      .call(@xAxis);

   
            
APP.charts['BoxPlotVertical'] = BoxPlotVertical
   