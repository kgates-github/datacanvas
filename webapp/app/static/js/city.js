// Generated by CoffeeScript 1.9.0
(function() {
  var App, config, helpers;

  helpers = {
    aqiColorClass: function(value) {
      switch (false) {
        case !(value <= 50):
          return 'good';
        case !(value <= 100):
          return 'moderate';
        case !(value <= 150):
          return 'unhealthy-mild';
        case !(value <= 200):
          return 'unhealthy';
        case !(value <= 300):
          return 'unhealthy-very';
        default:
          return 'hazardous';
      }
    }
  };

  config = {
    charts: [
      {
        type: 'BoxPlot',
        params: {
          el: 'ranking-airquality_raw',
          chart: 'ranking',
          dimension: 'airquality_raw',
          scale: d3.scale.linear,
          width: 700,
          height: 250,
          margin: {
            top: 30,
            right: 50,
            bottom: 30,
            left: 165
          }
        }
      }
    ]
  };

  App = (function() {
    function App(_at_config, _at_data, city, helpers) {
      var chart, data, _i, _len, _ref;
      this.config = _at_config;
      this.data = _at_data;
      this.charts = [];
      _ref = this.config.charts;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        chart = _ref[_i];
        data = _.findWhere(this.data, {
          dimension: chart.params.dimension,
          chart: chart.params.chart
        });
        this.charts.push(new APP.charts[chart.type](this, chart.params, data.data, city, helpers));
      }
    }

    return App;

  })();

  this.app = new App(config, data, city, helpers);

}).call(this);
