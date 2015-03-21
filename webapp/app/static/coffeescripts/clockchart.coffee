
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

    @filter 
      .append("filter")
      .attr("id", "blur")
      .append("feGaussianBlur")
      .attr("stdDeviation", 8)

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

    #console.log @cityData

    @cityContainers = @svg.selectAll("g")
      .data(@cityData)
      .enter()
      .append("g")
      .attr("transform", (d, i) ->
        #"translate(#{(i % 2 * 85)}, #{60+i*80})"
        "translate(#{(i % 2 * 85)}, #{60+i*80})"
      )
      .attr("id", (d, i) ->
        "id-#{i}"
      )
      .attr("class", "city")
      .attr("filter", (d) ->
        "url(#blur)"
      )

    @cityContainers
      .append("g")
      .attr("transform", (d, i) ->
        #"translate(#{(i % 2 * 85)}, #{60+i*80})"
        if i == 0
          return "translate(0, -50)"
        "translate(0, -20)"
      )
      .attr("class", "cityText")
      .style("opacity", 1)
      .append("text")
      .text((d) ->
        "#{d.city}"
      )
      .attr("x", 0)
      .attr("y", (d, i) ->
        if i == 0
          return 100
        else if d.city == "Boston"
          return -40
        -100
      )
      .style("opacity", 0.0)
      .style("font-size", "14px")
      .style("font-weight", "bold")
      

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

      @day.each((d, i) ->
        highest = _.max(d, (elem) -> elem.score)

        date = moment(highest.timestamp)
        
        date.format('MMM-Do-YY') #+ '-' + et.format('ha')

        index = containerIndex
        score = d3.select(@)
          .append("g")
          .attr("class", "dayText")
          .attr("opacity", 0)
        score
          .attr("transform", (d, i) ->
            if index == 0
              return "translate(0, 70)"
            else if index == 4
              return "translate(0, -88)"
            else if index == 5
              return "translate(0, -108)"
            "translate(0, 90)"
          )
        score
          .append("text")
          .attr("y", 0)
          .style("font-weight", "bold")
          .text(highest.score)
        score
          .append("text")
          .attr("y", 20)
          .text(date.format('MMMM DD'))
        score
          .append("text")
          .attr("y", 40)
          .text(date.format('ha'))
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
      .on("click", (d) ->
        window.location.href = "/city/#{d.city}/"
      )
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



  blurCity: (idx) ->
    null
    #.attr("filter", (d) => 
    #  "url(#blur)"
    #)
    

   
APP.charts['ClockChart'] = ClockChart
