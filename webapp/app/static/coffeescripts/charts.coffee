class Chart

  constructor: (@app, @params) ->

  
class BoxPlot extends Chart

  constructor: (@app, @params, @data) ->
    @el = @params.el
    @scaleX = @_getScaleX()
    @scaleY = @_getScaleY()

    @svg = d3.select("##{@el}").append("svg")
      .attr("width", @params.width)
      .attr("height", @params.height)

    @chart = @svg.append("g")
      .attr("transform", "translate(#{@params.margin.left}, #{@params.margin.top})")

    @data = @_sortBy(@data, "median")
    @plots = @chart.selectAll("rect")
      .data(@data)
      .enter()
      .append("rect")
      .attr("width", (d) => @scaleX(d.upper))
      .attr("height", 3)
      .attr("x", (d) => @scaleX(d.lower))
      .attr("y", (d, i) => @scaleY(i))
      .style("fill", "#ccc")

    @medians = @chart.selectAll("circle")
      .data(@data)
      .enter() 
      .append("circle")
      .attr("class", "good")
      .attr("r", 6)
      .attr("cx", (d) => @scaleX(d.median))
      .attr("cy", (d, i) => @scaleY(i) + 3)

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
   