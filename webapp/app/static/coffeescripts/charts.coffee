class Chart

  constructor: (@app, @params, @data, @helpers) ->

  
class BoxPlot extends Chart

  constructor: (@app, @params, @data, @helpers) ->

    @data = @_sortBy(@data, "median")
    @el = @params.el
    @scaleX = @_getScaleX()
    @scaleY = @_getScaleY()

    @svg = d3.select("##{@el}").append("svg")
      .attr("width", @params.width)
      .attr("height", @params.height)

    @chart = @svg.append("g")
      .attr("transform", "translate(#{@params.margin.left}, #{@params.margin.top})")

    @plots = @chart.selectAll(".plot")
      .data(@data)
      .enter()
      .append("g")
      .attr("class", "plot")
      .attr("transform", (d, i) =>
        "translate(0, #{@scaleY(i)})"
      )

    that = @

    @plots.each((d, i) ->
      d3.select(@).append("rect")
        .attr("width", (d) -> that.scaleX(d.upper) - that.scaleX(d.lower))
        .attr("height", 3)
        .attr("x", (d) -> that.scaleX(d.lower))
        .style("fill", "#ccc")

      d3.select(@).append("circle")
        .attr("class", "lower")
        .attr("class", (d) -> that.helpers.aqiColorClass(d.lower))
        .style("fill", "white")
        .attr("r", 5)
        .attr("cx", (d) -> that.scaleX(d.lower))
        .attr("cy", (d, i) -> that.scaleY(i) + 1)

      d3.select(@).append("circle")
        .attr("class", "median")
        .attr("class", (d) -> that.helpers.aqiColorClass(d.median))
        .attr("r", 5)
        .attr("cx", (d) -> that.scaleX(d.median))
        .attr("cy", (d, i) -> that.scaleY(i) + 1)

      d3.select(@).append("circle")
        .attr("class", "upper")
        .attr("class", (d) -> that.helpers.aqiColorClass(d.upper))
        .style("fill", "white")
        .attr("r", 5)
        .attr("cx", (d) -> that.scaleX(d.upper))
        .attr("cy", (d, i) -> that.scaleY(i) + 1)
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

  _sortBy: (data, dimension='median') ->
    _.sortBy(data, dimension).reverse()

  _getDomain: (data) ->
    max = _.max(_.pluck(data, "upper"))
    min = _.min(_.pluck(data, "lower"))
    [min, max]

    
        
            
window.APP ?= {}
APP.charts =
  BoxPlot: BoxPlot
   