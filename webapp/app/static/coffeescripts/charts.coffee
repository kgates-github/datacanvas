class Chart

  constructor: (@app, @params) ->
        

class BoxPlot extends Chart

  constructor: (@app, @params) ->
        
            
window.APP ?= {}
APP.charts =
  BoxPlot: BoxPlot
   