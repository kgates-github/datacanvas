class Chart

  constructor: (@app, @params) ->
        

class BoxPlot extends Chart

  constructor: (@app, @params, @data) ->
    @el = @params.el
    @svg = d3.select("##{@el}").append("svg")
      .attr("width", @params.width)
      .attr("height", @params.height)

    @data = @sortBy(@data, "median")
    
    @svg.append("rect")
      .attr("width", 100)
      .attr("height", 100)
      .style("fill", "red")

  sortBy: (data, dimension='median') ->
    _.sortBy(data, dimension).reverse()
    
        
            
window.APP ?= {}
APP.charts =
  BoxPlot: BoxPlot
   