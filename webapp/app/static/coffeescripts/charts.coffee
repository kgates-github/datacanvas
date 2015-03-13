class Chart

  constructor: (@app, @params, @data, @helpers) ->

  
class BoxPlot extends Chart

  constructor: (@app, @params, @data, @city, @helpers) ->

    self = @
    @data = _.sortBy(@data, "median")
    @el = @params.el
    @scaleX = @_getScaleX()
    @scaleY = @_getScaleY()
    @qualitative = @params.qualitative or []
    
    # Sorting controls
    $("##{@params.dimension}-sort button").on("click", ->
      self._sortBy($(this).val())
    )

    @svg = d3.select("##{@el}").append("svg")
      .attr("width", @params.width)
      .attr("height", @params.height)

    @chart = @svg.append("g")
      .attr("transform", "translate(#{@params.margin.left}, #{@params.margin.top})")

    @qualatativeTicks = @chart.selectAll("line")
      .data(@qualitative)
      .enter()
      .append("g")
      .attr("transform", (d, i) =>
        "translate(#{@scaleX(d.value)}, 0)"
      )

    @qualatativeTicks.each((d, i) ->
      y2 = self.params.height - (self.params.margin.top + self.params.margin.bottom) + 10
      d3.select(@)
        .append("line")
        .attr("y1", 0)
        .attr("y2", y2)
        .attr("stroke-dasharray", "3,5")
        .style("stroke-width", 1.5)
        .attr("class", (d) -> d.class)

      d3.select(@)
        .append("text")
        .attr("text-anchor", "end")
        .text((d) -> d.name)
        .attr("x", -6)
        .attr("y", y2)
        .attr("class", (d) -> d.class)
        .style("stroke", "none")
        .style("font-size", "11")
    )
    
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
      if self.city is d.name
        d3.select(@).append("rect")
          .attr("width", 120)
          .attr("height", 21)
          .attr("x", (d) -> -self.params.margin.left + 20)
          .attr("y", -9)
          .style("fill", "#333")
          .style("stroke", "#333")

      d3.select(@).append("text")
        .text(d.name)
        .attr("x", -self.params.margin.left + 32)
        .attr("y", 6)
        .attr("fill", (d) ->
          if self.city == d.name then "white" else "black"
        )

      d3.select(@).append("rect")
        .attr("width", (d) -> self.scaleX(d.upper) - self.scaleX(d.lower))
        .attr("height", 3)
        .attr("x", (d) -> self.scaleX(d.lower))
        .style("fill", "#ccc")

      d3.select(@).append("circle")
        .attr("class", (d) -> "lower #{self.helpers.getColorClass(d.lower, self.qualitative)}")
        .style("fill", "white")
        .attr("r", 5)
        .attr("cx", (d) -> self.scaleX(d.lower))
        .attr("cy", (d, i) -> self.scaleY(i) + 1)

      d3.select(@).append("circle")
        .attr("class", (d) -> "median #{self.helpers.getColorClass(d.median, self.qualitative)}")
        .attr("r", 5)
        .attr("cx", (d) -> self.scaleX(d.median))
        .attr("cy", (d, i) -> self.scaleY(i) + 1)

      d3.select(@).append("circle")
        .attr("class", (d) -> "upper #{self.helpers.getColorClass(d.upper, self.qualitative)}")
        .style("fill", "white")
        .attr("r", 5)
        .attr("cx", (d) -> self.scaleX(d.upper))
        .attr("cy", (d, i) -> self.scaleY(i) + 1)
    )

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
    @params.scale()
      .domain(domainY)
      .range(rangeY)

  _sortBy: (dimension='median') ->
    @data = _.sortBy(@data, dimension)

    @plots
      .data(@data, (d) -> d.name)
      .transition()
      .delay((d, i) -> i * 60)
      .duration(230)
      .ease("linear")
      .attr("transform", (d, i) =>
        "translate(0, #{@scaleY(i)})"
      )

  _getDomain: (data) ->
    max = _.max(_.pluck(data, "upper"))
    min = _.min(_.pluck(data, "lower"))
    [min, max]

    
        
            
window.APP ?= {}
APP.charts =
  BoxPlot: BoxPlot
   