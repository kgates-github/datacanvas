
class TweenChart extends APP.charts['Chart']

  constructor: (@app, @params, @data, @helpers) ->
    self = @
    @el = @params.el
    @qualitative = @params.qualitative or []
    @columnChart = null
    @columnViewOpen = false

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

     # Tooltip
    @tip = d3.tip()
      .attr('class', 'd3-tip-intro')
      .offset((d) =>
        [-40, 0]
      )
      .html((d) ->
        date = moment(d.timestamp)
        html = """
          <div>#{date.format('ha MMMM DD')}</div>
          <div>Air quality score: <strong style="color:#{d.color};">#{d.score}</strong></div>
        """
        html
      )

    @svg.call(@tip)

    @filter = @svg.append("defs")

    @filter 
      .append("filter")
      .attr("id", "blur")
      .append("feGaussianBlur")
      .attr("stdDeviation", 7)

    @filter 
      .append("filter")
      .attr("id", "blurMore")
      .append("feGaussianBlur")
      .attr("stdDeviation", 20)

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

    @mainContainer = @svg.append("g")
    @cityTranslate = {}

    @cityContainers = @mainContainer.selectAll("g")
      .data(@cityData)
      .enter()
      .append("g")
      .attr("transform", (d, i) =>
        @cityTranslate[d.city] = "translate(#{(i % 2 * 85 + 0)}, #{60+i*70})"
        @cityTranslate[d.city]
      )
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

      @day.each((d, i) ->
        date = moment(d[0].timestamp)
        
        #date.format('MMM-Do-YY') #+ '-' + et.format('ha')

        index = containerIndex
        score = d3.select(@)
          .append("g")
          .attr("class", "dayText")
          .attr("opacity", 0)
        score
          .attr("transform", (d, i) ->
            if index == 4
              return "translate(0, -48)"
            else if index == 5
              return "translate(0, -48)"
            "translate(0, 70)"
          )
       
        score
          .append("text")
          .attr("class", "radial-date")
          .style("fill", "#999")
          .attr("y", 0)
          .attr("text-anchor", "middle")
          .text(date.format('MMMM DD'))
      )

      d3.select(@)
        .style("cursor", "pointer")
        .on("click", (e) =>
          if !self.columnViewOpen
            self.tweenToColumns(@)
        )
    )
    @svg.selectAll(".city")
      .append("rect")
      .attr("y", -@params.height / 14)
      .attr("width", @params.width)
      .attr("height", @params.height / 6)
      .style("opacity", 0.0)
      .on("mouseover", (d, i) =>
        if !@columnViewOpen
          self.unBlurCity("id-#{i}", i, d)
      )
      #.on("mouseout", (d, i) =>
      #  if @columnViewOpen
      #    @blurCities()
      #)
      #.on("click", (d) ->
      #  window.location.href = "/city/#{d.city}/"
      #)
      .style("cursor", "pointer")

    @svg
      .on("mouseout", () =>
        if !@columnViewOpen
          @resetBlur()
      )

  createColumns: (elem) ->
    self = @
    scaleY = d3.scale.linear()
      .domain([0, 380])
      .range([0, 200])

    data = elem.__data__.data
    g = d3.select(elem)
    
    container = @svg.append("g")
      .attr("transform", g.attr("transform"))

    data.forEach((dayData, i) ->
      day = container
        .append("g")
        .attr("class", "columnGroup")
        .attr("transform", "translate(#{(50 + i*190)}, 0)")
        
      bars = day.selectAll(".bar")
        .data(dayData)
        .enter()
        .append("rect")
        .attr("class", "bar")
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

      day.selectAll("overlay")
        .data(dayData)
        .enter()
        .append("rect")
        .attr("x", (d, i) ->
          -50 + i * 7.9
        )
        .attr("y", -50)
        .attr("width", 10)
        .attr("height", 100)
        .attr("opacity", 0)
        .on('mouseover', self.tip.show)
        .on('mouseout', self.tip.hide)
    )

    return container

  openColumns: (columnChart, elem) ->
    self = @
    columnChart.attr("transform", "translate(0, 248)")
    city = elem.__data__.data[0][0].label

    d3.select("#intro-button")
      .on("click", ->
        window.location.href = "/city/#{city}/"
      )

    d3.select("#intro-close") 
      .on("click", ->
        self.tweenToRadial(columnChart, elem)
      )

    d3.select("#intro-text-city").html(city)

    columnChart.selectAll("g")
      .selectAll(".bar")
      .transition()
      .duration(700)
      .attr("width", 4)
      .attr("x", (d, i) ->
        -50 + i * 7.9
      ).each("end", (d, i) =>
        if i == 0
          $(".intro").show()
      )

  tweenToColumns: (elem) ->
    self = @
    @columnViewOpen = true

    arcTween = (transition, newStartAngle, newEndAngle) ->
      transition.attrTween("d", (d) ->
        interpolateEnd = d3.interpolate(d.endAngle, newEndAngle)
        interpolatestart = d3.interpolate(d.startAngle, newStartAngle)
        (t) ->
          d.startAngle = interpolateEnd(t)
          d.endAngle = interpolatestart(t)
          self.arc(d)
      )

    @columnViewOpen = true

    d3.select("#intro-text")
      .transition()
      .duration(750)
      .style("top", "230px")

    d3.select(elem)
      .transition()
      .duration(750)
      .attr("transform", "translate(0, 248)")
      .each("end", (d, i) =>
        @columnChart = @createColumns(elem)
        
        d3.select(elem).selectAll(".middleSolidArc")
          .transition()
          .duration(750)
          .call(arcTween, 0, 0)
          .each("end", (d, i) =>
            if i == 0 
              @openColumns(@columnChart, elem)
          )
      )

  tweenToRadial: (columnChart, elem) ->
    self = @
    arcTween = (transition, newStartAngle, newEndAngle) ->
      transition.attrTween("d", (d) ->
        interpolateEnd = d3.interpolate(d.endAngle, newEndAngle)
        interpolatestart = d3.interpolate(d.startAngle, newStartAngle)
        (t) ->
          d.startAngle = interpolateEnd(t)
          d.endAngle = interpolatestart(t)
          self.arc(d)
      )

    $(".intro").hide()
    called = false

    d3.selectAll(".columnGroup")
      .selectAll("rect")
      .transition()
      .duration(700)
      .attr("x", 0)
      .each("end", (d, i) =>

        if i == 0 and !called
          called = true
          d3.selectAll(".columnGroup").remove()
          
          city = elem.__data__.city 
          data = _.findWhere(@cityData, {"city": city}).data
          days = d3.select(elem).selectAll(".day")

          d3.select(elem)
            .attr("filter", "url(#unblur)")
          
          called2 = false
          days.each((d, i) ->
            radials = d3.select(@).selectAll(".middleSolidArc")
            d1 = self.pie(data[i])
            
            radials.each((d, i) ->
              d3.select(@)
                .transition()
                .duration(750)
                .call(arcTween, d1[i].startAngle, d1[i].endAngle)
                .each("end", (d, i) =>
                  
                  if i == 0 and !called2
                    called2 = true
                    d3.select(elem)
                      .attr("filter", "url(#unblur)")
                      .transition()
                      .duration(550)
                      .attr("transform", self.cityTranslate[city])
                      .each("end", (d, i) =>
                        if i == 0
                          #self.resetBlur()
                          self.columnViewOpen = false
                      )
                )
            )
          )
      )

  resetBlur: ->
    if !@columnViewOpen
      $("#intro-text").hide()
    d3.selectAll(".city")
      .attr("filter", (d) => 
        "url(#blur)"
      )
      .attr("opacity", 1)

    d3.selectAll(".day .dayText")
      .style("opacity", 0)

  unBlurCity: (idx, index, d) ->
    if d.city == 'Bangalore' or d.city == 'Boston'
      $("#intro-text").css(("top": "370px"))
    else
      $("#intro-text").css(("top": "230px"))

    $("#intro-text").show()
    d3.select("#intro-text-city").html(d.city)

    d3.selectAll(".city")
      .attr("filter", (d) -> 
        "url(#blur)"
      )
      .attr("opacity", 0.3)
    
    d3.selectAll("##{idx}")
      .attr("filter", (d) => 
        #@showText(d, index)
        "url(#unblur)"
      )
      .selectAll("text")
      .style("opacity", 1)

    d3.selectAll("##{idx} .dayText")
      .style("opacity", 1)

    d3.selectAll("##{idx}")
      .attr("opacity", 1.0)


  blurCities: ->
    console.log "un"
    #d3.selectAll(".city").attr("filter", (d) => 
    #  "url(#blur)"
    #)
    d3.selectAll(".cityText text")
      .style("opacity", 0)



   
APP.charts['TweenChart'] = TweenChart
