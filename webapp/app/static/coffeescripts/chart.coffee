
class Chart

  constructor: (@app, @params, @data, @city, @helpers) ->
    null

  _isAboveTheFold: -> 
    $(window).scrollTop() + $(window).height() > $("##{@el}").offset().top
  
  _getDuration: ->
    return if @_isAboveTheFold() then 1000 else 0
            
window.APP ?= {}
APP.charts =
  Chart: Chart
   