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
      }, {
        name: 'Unhealthy',
        "class": 'unhealthy',
        value: 200
      }, {
        name: 'Very unhealthy',
        "class": 'unhealthy-very',
        value: 300
      }, {
        name: 'Hazardous',
        "class": 'hazardous',
        value: 500
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
        type: 'Filter',
        params: {
          el: 'filter-container',
          chart: 'filter',
          dimension: 'none',
          scale: d3.scale.linear,
          width: 110,
          height: 530,
          qualitative: helpers.aqiQualitative,
          margin: {
            top: 0,
            right: 10,
            bottom: 10,
            left: 5
          }
        }
      }, {
        type: 'BoxPlot',
        params: {
          el: 'ranking-airquality_raw',
          chart: 'ranking',
          dimension: 'airquality_raw',
          scale: d3.scale.linear,
          width: 700,
          height: 290,
          qualitative: helpers.aqiQualitative,
          margin: {
            top: 40,
            right: 50,
            bottom: 40,
            left: 165
          }
        }
      }, {
        type: 'AreaChart',
        params: {
          el: 'timeseries-airquality_raw',
          chart: 'timeseries',
          dimension: 'airquality_raw',
          scaleX: d3.time.scale,
          scaleY: d3.scale.linear,
          width: 700,
          height: 330,
          qualitative: helpers.aqiQualitative,
          margin: {
            top: 10,
            right: 0,
            bottom: 40,
            left: 30
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
        if (data != null) {
          this.charts.push(new APP.charts[chart.type](this, chart.params, data.data, city, helpers));
        }
      }
    }

    App.prototype.update = function(_at_data) {
      var chart, data, _i, _len, _ref, _results;
      this.data = _at_data;
      _ref = this.charts;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        chart = _ref[_i];
        data = _.findWhere(this.data, {
          dimension: chart.params.dimension,
          chart: chart.params.chart
        });
        _results.push(chart.update(data.data));
      }
      return _results;
    };

    return App;

  })();

  this.app = new App(config, data, city, helpers);

  $("#filter-container").on("click", (function(_this) {
    return function(e) {
      return _this.app.update(fakeData);
    };
  })(this));

}).call(this);
