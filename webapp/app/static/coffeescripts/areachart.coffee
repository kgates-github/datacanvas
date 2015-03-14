
class AreaChart extends APP.charts['Chart']

  constructor: (@app, @params, @data, @city, @helpers) ->
    
    self = @
    @el = @params.el
    @scaleX = @_getScaleX()
    @scaleY = @_getScaleY() 
    @qualitative = @params.qualitative or []
    @xAxis = d3.svg.axis().scale(@scaleX).tickSize(-6).tickSubdivide(true)

    @svg = d3.select("##{@el}").append("svg")
      .attr("width", @params.width)
      .attr("height", @params.height)

    # X axis
    @svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(#{@params.margin.left}, #{@params.height})")
      .call(@xAxis);

    @chart = @svg.append("g")
      .attr("transform", "translate(#{@params.margin.left}, #{@params.margin.top})")
  
    @areaMax = d3.svg.area()
      .x((d) => @scaleX(new Date(d.date)))
      .y0((d) =>  @scaleY(d.min))
      .y1((d) => @scaleY(d.max))

    @chart.append("path")
      .datum(@data)
      .attr("class", "area")
      .style("fill", "#eee")
      .attr("d", @areaMax)

    @areaPercentiles = d3.svg.area()
      .x((d) => @scaleX(new Date(d.date)))
      .y0((d) =>  @scaleY(d.lower))
      .y1((d) => @scaleY(d.upper))

    @chart.append("path")
      .datum(@data)
      .attr("class", "area")
      .style("fill", "#ddd")
      .attr("d", @areaPercentiles)
    

  _getDomain: (data) ->
    max = _.max(_.pluck(data, "max"))
    min = _.min(_.pluck(data, "min"))
    [min, max]

  _getScaleX: ->
    domainX = d3.extent(@data, (d) -> d.date)
    rangeX = [
        0, @params.width - (@params.margin.left + @params.margin.right)
      ]

    console.log rangeX

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
            
APP.charts['AreaChart'] = AreaChart
   