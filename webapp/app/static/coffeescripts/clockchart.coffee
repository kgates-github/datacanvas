
class ClockChart extends APP.charts['Chart']

  constructor: (@app, @params, @data, @helpers) ->
    self = @
    @el = @params.el
    @qualitative = @params.qualitative or []

    @width = 250
    @height = 250
    @radius = Math.min(@width, @height) / 2
    @innerRadius = 0
    @interval = 0

    @scale = d3.scale.linear()
      .domain([0, 350])
      .range([0, 1])

    @pie = d3.layout.pie()
      .sort(null)
      .value((d) -> d.width)

    @arc = d3.svg.arc()
      .innerRadius(@innerRadius)
      .outerRadius((d, i) =>
        ((@radius - @innerRadius) * (@scale(d.data.score)) + @innerRadius)
      )
    

    @svg = d3.select("##{@el}").append("svg")
      .attr("width", @params.width)
      .attr("height", @params.height)

    @filter = @svg.append("defs")
      .append("filter")
      .attr("id", "blur")
      .append("feGaussianBlur")
      .attr("stdDeviation", 8)

    @cities = ["Bangalore", "Boston", "Rio de Janeiro", "San Francisco", "Shanghai", "Singapore"]
    @cityData = []
    for city in @cities
      cityData = _.groupBy(_.where(@data, {"city": city}), (d) -> d.timestamp.substring(0,10))
      
      data = []
      for date of cityData
        data.push _.map(cityData[date], (d, i) -> 
          {
              'id': "#{d.city}-#{i}"
              'order': i
              'color': self.helpers.getColor(d.airquality_raw, self.qualitative)
              'weight': 1
              'score': d.airquality_raw
              'width': 1
              'label': city
              'timestamp': d.timestamp
            }
        )

      @cityData.push(
        {
          city: city
          data: data
        }
      )

    #console.log @cityData

    @cityContainers = @svg.selectAll("g")
      .data(@cityData)
      .enter()
      .append("g")
      .attr("transform", (d, i) ->
        #"translate(#{(i % 2 * 85)}, #{60+i*80})"
        "translate(#{(i % 2 * 85)}, #{60+i*80})"
      )
      .attr("filter", (d) ->
        if d.city != "Rio de Janeiro"
          "url(#blur)"
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
          "translate(#{(50 + i*190)}, 0)"
        )
      
      @day.each((d, i) ->
        
        @path = d3.select(@).selectAll(".middleSolidArc")
          .data(self.pie(d))
          .enter().append("path")
          .attr("fill", (d) ->
            
            if d.data.score > 50
              return d.data.color
            "none"
          )
          .style("opacity", 1.0)
          .attr("class", "middleSolidArc")
          .attr("stroke", "#fff")
          .attr("stroke-width", 1.5)
          .attr("d", self.arc)

        d3.select(@)
          .append("circle")
          .attr("cx", 0)
          .attr("cy", 0)
          .attr("r", 2)
          .style("fill", "#666")
      )
    )

   
APP.charts['ClockChart'] = ClockChart
