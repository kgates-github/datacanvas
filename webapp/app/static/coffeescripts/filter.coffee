
class Filter extends APP.charts['Chart']

  constructor: (@app, @params, @data, @city, @helpers) ->
    self = @
    @data = _.sortBy(@data, "median")
    @el = @params.el
    @scaleX = @_getScaleX()
    @scaleY = @_getScaleY()
    @qualitative = @params.qualitative or []
    @xAxis = d3.svg.axis().scale(@scaleX).tickSize(-6).tickSubdivide(true)
    
    @dataMonthly = _.findWhere(@data, 
      {
        dimension: @params.dimension, 
        chart: 'monthly'
      }
    )
    @dataMonthly =  @dataMonthly.data
    @buttonsMonthly = d3.select("##{@el}").append("div")
      .attr("class", "btn-group-vertical")

    @buttonsMonthly.selectAll("button")
      .data(@dataMonthly)
      .enter()
      .append("button")
      .attr("type", "button")
      .attr("class", "btn btn-default btn-sm btn-compact")
      .html((d) ->
        d.date
      )

    ###
    <div class="btn-group-vertical" role="group" aria-label="">
        <button type="button" class="btn btn-default btn-sm btn-compact">Jan</button>
        <button type="button" class="btn btn-default btn-sm btn-compact">Feb</button>
        <button type="button" class="btn btn-default btn-sm btn-compact">Mar</button>
    

    # X axis
    @svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(#{@params.margin.left}," + (@params.height - 30) + ")")
      .call(@xAxis)
    ###
    

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

  _getDomain: (data) ->
    max = _.max(_.pluck(data, "upper"))
    min = _.min(_.pluck(data, "lower"))
    [min, max]

  update: (data) ->
    self = @
    @data = data
    @scaleX = @_getScaleX()
    
    
            
APP.charts['Filter'] = Filter
   