
class CircleChart extends APP.charts['Chart']

  constructor: (@app, @params, @data, @helpers) ->
    self = @
    @el = @params.el
    
    @qualitative = @params.qualitative or []
    

    @svg = d3.select("##{@el}").append("svg")
      .attr("width", @params.width)
      .attr("height", @params.height)

    @cities = ["Bangalore", "Boston", "Geneva", "Rio de Janeiro", "San Francisco", "Shanghai", "Singapore"]
    @cityData = []
    for city in @cities
      cityData = _.groupBy(_.where(@data, {"city": city}), (d) -> d.timestamp.substring(0,10))
      
      data = []
      for date of cityData
        data.push _.filter(cityData[date], (d, i) -> 
          d.airquality_raw > 100 and d.city != 'Geneva')

      @cityData.push(
        {
          city: city
          data: data
        }
      )

    @cityContainers = @svg.selectAll("g")
      .data(@cityData)
      .enter()
      .append("g")
      .attr("transform", (d, i) ->
        "translate(0, #{60+i*50})"
      )

   
    @cityContainers.each((d, i) ->
      ###
      d3.select(@).append("text")
        .text(d.city)
        #.attr("transform", "rotate(-90)")
        .attr("y", 4)
        #.attr("dx", "0.8em")
        .style("text-anchor", "start")
        .style("font-size", "11px")
        .style("stroke", "none")
        .style("fill", "#999")
      ###

      @day = d3.select(@).selectAll(".day")
        .data(d.data)
        .enter()
        .append("g")
        .attr("class", "day")
        .attr("transform", (d, i) ->
          "translate(#{50+ i*100}, 0)"
        )
      
      @day.each((d, i) ->
        #console.log d
        
        d3.select(@).selectAll("circle")
          .data(d)
          .enter()
          .append("circle")
          .attr("cx", 0)
          .attr("cy", 0)
          .attr("r", (d, i) =>
            i * 4
          )
          .style("fill", "none")
          .style("opacity", 0.7)
          .style("stroke", (d, i) =>
            
            if d.airquality_raw > 100
              return self.helpers.getColor(d.airquality_raw, self.qualitative)
            "none"
          )
          .style("stroke-width", 1.5)
          .attr("class", "circle")

        d3.select(@)
          .append("circle")
          .attr("cx", 0)
          .attr("cy", 0)
          .attr("r", 2)
          .style("fill", "#999")
      )
    )

    ###
    @cities.each((d, i) ->

      @cityData = _.where(@data, {city: d})
      #@rioData = _.filter(@rioData, (d) -> d.airquality_raw > 50)

      @g = @svg.append("g")
        .attr("class", d)
        .attr("transform", "translate(200, 200)")
        
      @g.selectAll(".circle")
        .data(@cityData)
        .enter()
        .append("circle")
        .attr("cx", 0)
        .attr("cy", 0)
        .attr("r", (d, i) =>
          console.log d
          i * 3
        )
        .style("fill", "none")
        .style("stroke", (d, i) =>
          console.log d.airquality_raw
          if d.airquality_raw > 100
            return @helpers.getColor(d.airquality_raw, @qualitative)
          "#fff"
        )
        .style("stroke-width", 1)
        .attr("class", "circle")
    )
    ###

    

   
APP.charts['CircleChart'] = CircleChart
   