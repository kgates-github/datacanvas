// Generated by CoffeeScript 1.9.0
(function() {
  var App, config, helpers;

  helpers = {
    getColorClass: function(value, qualitative) {
      var setting, _i, _len;
      if (value == null) {
        value = Infinity;
      }
      if (qualitative == null) {
        qualitative = [];
      }
      for (_i = 0, _len = qualitative.length; _i < _len; _i++) {
        setting = qualitative[_i];
        if (value <= setting.value) {
          return setting["class"];
        }
      }
      return false;
    },
    aqiQualitative: [
      {
        name: 'Good',
        "class": 'good',
        value: 50
      }, {
        name: 'Moderate',
        "class": 'moderate',
        value: 100
      }, {
        name: 'Mildly unhealthy',
        "class": 'unhealthy-mild',
        value: 150
      }
    ],
    soundQualitative: [
      {
        name: 'Quiet suburb',
        "class": 'moderate',
        value: 50
      }, {
        name: 'Rock concert',
        "class": 'unhealthy-mild',
        value: 100
      }
    ]
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
          qualitative: helpers.aqiQualitative,
          margin: {
            top: 40,
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
