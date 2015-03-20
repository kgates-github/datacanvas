// Generated by CoffeeScript 1.9.0
(function() {
  var ClockChart,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __hasProp = {}.hasOwnProperty;

  ClockChart = (function(_super) {
    __extends(ClockChart, _super);

    function ClockChart(_at_app, _at_params, _at_data, _at_helpers) {
      var city, cityData, data, date, self, _i, _len, _ref;
      this.app = _at_app;
      this.params = _at_params;
      this.data = _at_data;
      this.helpers = _at_helpers;
      self = this;
      this.el = this.params.el;
      this.qualitative = this.params.qualitative || [];
      this.width = 250;
      this.height = 250;
      this.radius = Math.min(this.width, this.height) / 2;
      this.innerRadius = 0;
      this.interval = 0;
      this.scale = d3.scale.linear().domain([0, 350]).range([0, 1]);
      this.pie = d3.layout.pie().sort(null).value(function(d) {
        return d.width;
      });
      this.arc = d3.svg.arc().innerRadius(this.innerRadius).outerRadius((function(_this) {
        return function(d, i) {
          return (_this.radius - _this.innerRadius) * (_this.scale(d.data.score)) + _this.innerRadius;
        };
      })(this));
      this.svg = d3.select("#" + this.el).append("svg").attr("width", this.params.width).attr("height", this.params.height);
      this.cities = ["Bangalore", "Boston", "Rio de Janeiro", "San Francisco", "Shanghai", "Singapore"];
      this.cityData = [];
      _ref = this.cities;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        city = _ref[_i];
        cityData = _.groupBy(_.where(this.data, {
          "city": city
        }), function(d) {
          return d.timestamp.substring(0, 10);
        });
        data = [];
        for (date in cityData) {
          data.push(_.map(cityData[date], function(d, i) {
            return {
              'id': d.city + "-" + i,
              'order': i,
              'color': self.helpers.getColor(d.airquality_raw, self.qualitative),
              'weight': 1,
              'score': d.airquality_raw,
              'width': 1,
              'label': city,
              'timestamp': d.timestamp
            };
          }));
        }
        this.cityData.push({
          city: city,
          data: data
        });
      }
      this.cityContainers = this.svg.selectAll("g").data(this.cityData).enter().append("g").attr("transform", function(d, i) {
        return "translate(" + (i % 2 * 85) + ", " + (60 + i * 80) + ")";
      });
      this.cityContainers.each(function(d, i) {

        /*
        d3.select(@).append("text")
          .text(d.city)
          #.attr("transform", "rotate(-90)")
          .attr("y", 4)
          #.attr("dx", "0.8em")
          .style("text-anchor", "start")
          .style("font-size", "11px")
          .style("stroke", "none")
          .style("fill", "#999")
         */
        this.day = d3.select(this).selectAll(".day").data(d.data).enter().append("g").attr("class", "day").attr("transform", function(d, i) {
          return "translate(" + (50 + i * 190) + ", 0)";
        });
        return this.day.each(function(d, i) {
          this.path = d3.select(this).selectAll(".middleSolidArc").data(self.pie(d)).enter().append("path").attr("fill", function(d) {
            if (d.data.score > 50) {
              return d.data.color;
            }
            return "none";
          }).style("opacity", 1.0).attr("class", "middleSolidArc").attr("stroke", "#fff").attr("stroke-width", 1.5).attr("d", self.arc);
          return d3.select(this).append("circle").attr("cx", 0).attr("cy", 0).attr("r", 2).style("fill", "#666");
        });
      });
    }

    return ClockChart;

  })(APP.charts['Chart']);

  APP.charts['ClockChart'] = ClockChart;

}).call(this);