
class ScoreCard extends APP.charts['Chart']

  constructor: (@app, @params, @data, @city, @helpers) ->
   @_setHTML()
   @_setExplanationText()
    
  _setHTML: ->
    good = _.filter(@data, (d) -> d.max <= 50)
    moderate = _.filter(@data, (d) -> d.max > 50 and d.max <= 100)
    unhealthyMild = _.filter(@data, (d) -> d.max > 100 and d.max <= 150)
    unhealthy = _.filter(@data, (d) -> d.max > 150 and d.max <= 200)
    unhealthyVery = _.filter(@data, (d) -> d.max > 200 and d.max <= 300)
    hazardous = _.filter(@data, (d) -> d.max > 300)

    html = """
      <table id="score-card" style="width:100%; font-size:11px;">
          <tr class="scores">
            <td class="good-score">
              #{good.length}
              <div style="font-size:11px;">Good</div>
            </td>
            <td class="moderate-score">
              #{moderate.length}
              <div style="font-size:11px;">Moderate</div>
            </td>
            <td class="unhealthy-mild-score">
              #{unhealthyMild.length}
              <div style="font-size:11px; line-height:12px;">Mildly unhealthy</div>
            </td>
            <td class="unhealthy-score">
              #{unhealthy.length}
              <div style="font-size:11px;">Unhealthy</div>
            </td>
            <td class="unhealthy-very-score">
              #{unhealthyVery.length}
              <div style="font-size:11px;">Very unhealthy</div>
            </td>
             <td class="hazardous-score">
              #{hazardous.length}
              <div style="font-size:11px;">Hazardous</div>
            </td>
          </tr>
          <tr class='score-text'>
            <td>
              Days highest AQI remained lower than 50
            </td>
            <td>
              Days highest AQI reach moderately unhealthy levels
            </td>
            <td>
              Days AQI reached mildly unhealthy levels
            </td>
            <td>
              Days AQI reached unhealthy levels
            </td>
            <td>
              Days AQI reached very unhealthy levels
            </td>
             <td>
              Days AQI reached hazardous levels
            </td>
          </tr>
        </table>
      """
    d3.select("##{@params.el}").html(html)


  update: (data) ->
    self = @
    @data = data
    @_setHTML()
    @_setExplanationText()

  _setExplanationText: ->
    @filters = @app.getFilters()
    monthText = if @filters.monthFilter then "#{@filters.monthFilter}, 2015" else \
      "between #{@filters.startMonth} and #{@filters.endMonth}, 2015"

    timeOfDayText = if @filters.timeOfDayFilter? then \
      " and only use data collected between #{@filters.timeOfDayFilter}" else ""

    html = """
      Measurements are from #{monthText}#{timeOfDayText}.
    """
    
    d3.select("#score-explanation").html(html)
    
    
            
APP.charts['ScoreCard'] = ScoreCard
   