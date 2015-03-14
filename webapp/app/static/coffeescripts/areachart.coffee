
class AreaChart extends APP.charts['Chart']

  constructor: (@app, @params, @data, @city, @helpers) ->
    
    self = @
    @el = @params.el
    @scaleX = @_getScaleX()
    @scaleY = @_getScaleY() 
    @qualitative = @params.qualitative or []
    @xAxis = d3.svg.axis().scale(@scaleX).tickSize(-6)
    @yAxis = d3.svg.axis().scale(@scaleY ).orient("left")

    @svg = d3.select("##{@el}").append("svg")
      .attr("width", @params.width)
      .attr("height", @params.height)

    # X axis
    @svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(#{@params.margin.left}, #{@params.height - @params.margin.bottom + 20})")
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
      .text("Air quality index")

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
      .style("fill", "#ddd")
      .attr("d", @areaPercentile)

    @line = d3.svg.line()
      .x((d) => @scaleX(new Date(d.date)))
      .y((d) => @scaleY(d.median))

    @areaMedianPlot = @chart.append("path")
      .datum(@data)
      .attr("class", "line")
      .attr("d", @line)

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
    @data = data
    @scaleX = @_getScaleX()
    @scaleY = @_getScaleY() 
    @xAxis = d3.svg.axis().scale(@scaleX).tickSize(-6)
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
      .duration(1000)
      .attr("d", @areaMax)

    @areaPercentilePlot
      .datum(@data)
      .transition()
      .duration(1000)
      .attr("d", @areaPercentile)

    @areaMedianPlot
      .datum(@data)
      .transition()
      .duration(1000)
      .attr("d", @line)

    # Update x axis
    @svg.selectAll("g.x.axis")
      .transition()
      .duration(1000)
      .call(@xAxis)

    @svg.selectAll("g.y.axis")
      .transition()
      .duration(1000)
      .call(@yAxis);


APP.charts['AreaChart'] = AreaChart
   