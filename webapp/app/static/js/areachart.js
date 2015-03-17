// Generated by CoffeeScript 1.9.0
(function() {
  var AreaChart,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __hasProp = {}.hasOwnProperty;

  AreaChart = (function(_super) {
    __extends(AreaChart, _super);

    function AreaChart(_at_app, _at_params, _at_data, _at_city, _at_helpers) {
      var self;
      this.app = _at_app;
      this.params = _at_params;
      this.data = _at_data;
      this.city = _at_city;
      this.helpers = _at_helpers;
      self = this;
      this.el = this.params.el;
      this.scaleX = this._getScaleX();
      this.scaleY = this._getScaleY();
      this.qualitative = this.params.qualitative || [];
      this.xAxis = d3.svg.axis().scale(this.scaleX).tickSize(-6);
      this.yAxis = d3.svg.axis().scale(this.scaleY).orient("left");
      this.svg = d3.select("#" + this.el).append("svg").attr("width", this.params.width).attr("height", this.params.height);
      this.tip = d3.tip().attr('class', 'd3-tip').offset([-20, -20]).html((function(_this) {
        return function(d) {
          var html, lowerClass, lowerName, medianClass, medianName, upperClass, upperName;
          lowerClass = self.helpers.getColorClass(d.lower, self.qualitative);
          lowerName = _.findWhere(self.qualitative, {
            "class": lowerClass
          }).name;
          medianClass = self.helpers.getColorClass(d.median, self.qualitative);
          medianName = _.findWhere(self.qualitative, {
            "class": medianClass
          }).name;
          upperClass = self.helpers.getColorClass(d.upper, self.qualitative);
          upperName = _.findWhere(self.qualitative, {
            "class": upperClass
          }).name;
          html = "<div style='margin-bottom:10px; font-size:11px; color:#bbb;'>" + _this.city + "'s Air Quality Index</div>\n<div style='margin-bottom:4px; color:white; font-size:20px; font-weight: 400;'>\n  " + (moment(d.date).format('MMM D, YYYY')) + "\n</div>\n         \n<table class=\"table borderless\">\n  <tbody>\n    <tr>\n      <td>\n        <div>Low</div>\n        <div style=\"font-size:11px; color:#bbb;\">10th<br>percentile</div>\n      </td>\n      <td style=\"text-align:center;\">\n        <div>Median</div>\n      </td>\n      <td style=\"text-align:right;\">\n        <div>High</div>\n        <div style=\"font-size:11px; color:#bbb;\">90th<br>percentile</div></td>\n    </tr>\n    <tr style=\"font-size:26px;\">\n      <td class=\"" + lowerClass + "\" style=\"width:70px; color:white; text-align:center;\">\n        " + (d3.round(d.lower, self.params.round)) + "\n        <div style=\"font-size:11px; color:#fff;\">" + lowerName + "</div></td>\n      </td>\n      <td class=\"" + medianClass + "\" style=\"width:70px; color:white; text-align:center;\">\n        " + (d3.round(d.median, self.params.round)) + "\n        <div style=\"font-size:11px; color:#fff;\">" + medianName + "</div></td>\n      </td>\n      <td class=\"" + upperClass + "\" style=\"width:70px; color:white; text-align:center;\">\n        " + (d3.round(d.upper, self.params.round)) + "\n        <div style=\"font-size:11px; color:#fff;\">" + upperName + "</div></td>\n      </td>\n    </tr>\n  </tbody>\n</table>";
          return html;
        };
      })(this));
      this.svg.call(this.tip);
      this.svg.append("g").attr("class", "x axis").attr("transform", "translate(20, " + (this.params.height - this.params.margin.bottom + 20) + ")").call(this.xAxis);
      this.svg.append("g").attr("class", "y axis").attr("transform", "translate(" + (this.params.margin.left - 1) + ", " + this.params.margin.top + ")").call(this.yAxis).append("text").attr("transform", "rotate(-90)").attr("y", 6).attr("dy", "0.8em").style("text-anchor", "end").style("font-size", "11px").text("Air quality index");
      this.chart = this.svg.append("g").attr("transform", "translate(" + this.params.margin.left + ", " + this.params.margin.top + ")");
      this.areaMax = d3.svg.area().x((function(_this) {
        return function(d) {
          return _this.scaleX(new Date(d.date));
        };
      })(this)).y0((function(_this) {
        return function(d) {
          return _this.scaleY(d.min);
        };
      })(this)).y1((function(_this) {
        return function(d) {
          return _this.scaleY(d.max);
        };
      })(this));
      this.areaMaxPlot = this.chart.append("path").datum(this.data).attr("class", "area").style("fill", "#eee").attr("d", this.areaMax);
      this.areaPercentile = d3.svg.area().x((function(_this) {
        return function(d) {
          return _this.scaleX(new Date(d.date));
        };
      })(this)).y0((function(_this) {
        return function(d) {
          return _this.scaleY(d.lower);
        };
      })(this)).y1((function(_this) {
        return function(d) {
          return _this.scaleY(d.upper);
        };
      })(this));
      this.areaPercentilePlot = this.chart.append("path").datum(this.data).attr("class", "area").style("fill", "#ddd").attr("d", this.areaPercentile);
      this.line = d3.svg.line().x((function(_this) {
        return function(d) {
          return _this.scaleX(new Date(d.date));
        };
      })(this)).y((function(_this) {
        return function(d) {
          return _this.scaleY(d.median);
        };
      })(this));
      this.areaMedianPlot = this.chart.append("path").datum(this.data).attr("class", "line").attr("d", this.line);
      this.chart.selectAll(".overlay").data(this.data).enter().append("rect").style("fill", "#333").style("opacity", 0.0).attr("class", "overlay").attr("height", this.params.height - (this.params.margin.top + this.params.margin.bottom)).attr("width", this.params.width / this.data.length).attr("x", (function(_this) {
        return function(d) {
          return _this.scaleX(new Date(d.date));
        };
      })(this)).attr("y", this.params.margin.top).on('mouseover', this.tip.show).on('mouseout', this.tip.hide);
    }

    AreaChart.prototype._getDomain = function(data) {
      var max, min;
      max = _.max(_.pluck(data, "max"));
      min = _.min(_.pluck(data, "min"));
      return [min, max];
    };

    AreaChart.prototype._getScaleX = function() {
      var domainX, rangeX;
      domainX = d3.extent(this.data, function(d) {
        return d.date;
      });
      rangeX = [0, this.params.width - (this.params.margin.left + this.params.margin.right)];
      return d3.time.scale().range(rangeX).domain([new Date(domainX[0]), new Date(domainX[1])]);
    };

    AreaChart.prototype._getScaleY = function() {
      var domainY, rangeY;
      domainY = this._getDomain(this.data);
      rangeY = [this.params.height - (this.params.margin.top + this.params.margin.bottom), 0];
      return this.params.scaleY().domain(domainY).range(rangeY);
    };

    AreaChart.prototype.update = function(data) {
      var duration;
      duration = this._getDuration();
      this.data = data;
      this.scaleX = this._getScaleX();
      this.scaleY = this._getScaleY();
      this.xAxis = d3.svg.axis().scale(this.scaleX).tickSize(-6);
      this.yAxis = d3.svg.axis().scale(this.scaleY).orient("left");
      this.areaMax = d3.svg.area().x((function(_this) {
        return function(d) {
          return _this.scaleX(new Date(d.date));
        };
      })(this)).y0((function(_this) {
        return function(d) {
          return _this.scaleY(d.min);
        };
      })(this)).y1((function(_this) {
        return function(d) {
          return _this.scaleY(d.max);
        };
      })(this));
      this.areaPercentile = d3.svg.area().x((function(_this) {
        return function(d) {
          return _this.scaleX(new Date(d.date));
        };
      })(this)).y0((function(_this) {
        return function(d) {
          return _this.scaleY(d.lower);
        };
      })(this)).y1((function(_this) {
        return function(d) {
          return _this.scaleY(d.upper);
        };
      })(this));
      this.line = d3.svg.line().x((function(_this) {
        return function(d) {
          return _this.scaleX(new Date(d.date));
        };
      })(this)).y((function(_this) {
        return function(d) {
          return _this.scaleY(d.median);
        };
      })(this));
      this.areaMaxPlot.datum(this.data).transition().duration(duration).attr("d", this.areaMax);
      this.areaPercentilePlot.datum(this.data).transition().duration(duration).attr("d", this.areaPercentile);
      this.areaMedianPlot.datum(this.data).transition().duration(duration).attr("d", this.line);
      this.svg.selectAll("g.x.axis").transition().duration(duration).call(this.xAxis);
      return this.svg.selectAll("g.y.axis").transition().duration(duration).call(this.yAxis);
    };

    return AreaChart;

  })(APP.charts['Chart']);

  APP.charts['AreaChart'] = AreaChart;

}).call(this);
