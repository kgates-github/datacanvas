
class TweenChart extends APP.charts['Chart']

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

    @filter 
      .append("filter")
      .attr("id", "blur")
      .append("feGaussianBlur")
      .attr("stdDeviation", 0)

    @filter 
      .append("filter")
      .attr("id", "unblur")
      .append("feGaussianBlur")
      .attr("stdDeviation", 0)

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

    @cityContainers = @svg.selectAll("g")
      .data(@cityData)
      .enter()
      .append("g")
      .attr("transform", (d, i) -> "translate(#{(i % 2 * 85 + 10)}, #{60+i*80})")
      .attr("id", (d, i) -> "id-#{i}")
      .attr("class", "city")
      .attr("filter", (d) ->
        "url(#blur)"
      )

    @cityContainers.each((d, i) ->
      containerIndex = i
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
            if d.data.score > 0
              return d.data.color
            "none"
          )
          .style("opacity", 1.0)
          .attr("class", "middleSolidArc")
          .attr("stroke", "#fff")
          .attr("stroke-width", 1.5)
          .attr("d", self.arc)
      )

      d3.select(@)
        .style("cursor", "pointer")
        .on("click", (e) =>
          self.tweenToColumns(@)
        )
    )
    @svg.selectAll(".city")
      .append("rect")
      .attr("y", -@params.height / 14)
      .attr("width", @params.width)
      .attr("height", @params.height / 7 - 20)
      .style("opacity", 0.0)
      .on("mouseover", (d, i) ->
        self.unBlurCity("id-#{i}", i)
      )
      .on("mouseout", (d, i) =>
        @blurCity()
      )
      #.on("click", (d) ->
      #  window.location.href = "/city/#{d.city}/"
      #)
      .style("cursor", "pointer")

    @svg
      .on("mouseout", () ->
        d3.selectAll(".city").attr("filter", (d) -> 
          "url(#blur)"
        )
        d3.selectAll(".cityText text")
          .style("opacity", 0)

        d3.selectAll(".day .dayText")
          .style("opacity", 0)
      )

  createColumns: (elem) ->
    self = @
    scaleY = d3.scale.linear()
      .domain([0, 180])
      .range([0, 80])

    data = elem.__data__.data
    g = d3.select(elem)
    
    container = @svg.append("g")
      .attr("transform", g.attr("transform"))

    data.forEach((dayData, i) ->
      day = container
        .append("g")
        .attr("transform", "translate(#{(50 + i*190)}, 0)")
        
      bars = day.selectAll("rect")
        .data(dayData)
        .enter()
        .append("rect")
        .attr("width", 0)
        .attr("height", (d) =>
          scaleY(d.score)
        )
        .style("stroke", "none")
        .style("fill", (d) ->
          d.color
        )
        .attr("x", 0)
        .attr("y", (d) ->
          20 - scaleY(d.score)
        )
    )

    return container

  openColumns: (columnChart) ->
    columnChart.selectAll("g")
      .selectAll("rect")
      #.style("fill", "#ffcc00")
      .transition()
      .duration(700)
      .attr("width", 4)
      .attr("x", (d, i) ->
        -50 + i * 7.9
      )
    

  tweenToColumns: (elem) ->
    self = @

    arcTween = (transition, newStartAngle, newEndAngle) ->
      transition.attrTween("d", (d) ->
        interpolateEnd = d3.interpolate(d.endAngle, newEndAngle)
        interpolatestart = d3.interpolate(d.startAngle, newStartAngle)
        return (t) ->
          d.startAngle = interpolateEnd(t)
          d.endAngle = interpolatestart(t)
          return self.arc(d)
      )

    columnChart = @createColumns(elem)
    
    d3.select(elem).selectAll(".middleSolidArc")
      .transition()
      .duration(750)
      .call(arcTween, 0, 0)
      .each("end", (d, i) =>
        if i == 0 
          @openColumns(columnChart)
      )

  unBlurCity: (idx, index) ->
    d3.selectAll(".city").attr("filter", (d) -> 
      "url(#blur)"
    )

    d3.selectAll(".cityText text")
      .style("opacity", 0)

    d3.selectAll(".day .dayText")
      .style("opacity", 0)
    
    d3.selectAll("##{idx}")
      .attr("filter", (d) => 
        #@showText(d, index)
        "url(#unblur)"
      )
      .selectAll("text")
      .style("opacity", 1)

    d3.selectAll("##{idx} .dayText")
      .style("opacity", 1)


  blurCities: ->
    d3.selectAll(".city").attr("filter", (d) => 
      "url(#blur)"
    )
    d3.selectAll(".cityText text")
      .style("opacity", 0)



   
APP.charts['TweenChart'] = TweenChart
