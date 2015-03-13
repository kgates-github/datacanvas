// Generated by CoffeeScript 1.9.0
(function() {
  var BoxPlot, Chart,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __hasProp = {}.hasOwnProperty;

  Chart = (function() {
    function Chart(_at_app, _at_params, _at_data, _at_helpers) {
      this.app = _at_app;
      this.params = _at_params;
      this.data = _at_data;
      this.helpers = _at_helpers;
    }

    return Chart;

  })();

  BoxPlot = (function(_super) {
    __extends(BoxPlot, _super);

    function BoxPlot(_at_app, _at_params, _at_data, _at_city, _at_helpers) {
      var self;
      this.app = _at_app;
      this.params = _at_params;
      this.data = _at_data;
      this.city = _at_city;
      this.helpers = _at_helpers;
      self = this;
      this.data = _.sortBy(this.data, "median");
      this.el = this.params.el;
      this.scaleX = this._getScaleX();
      this.scaleY = this._getScaleY();
      this.qualitative = this.params.qualitative || [];
      this.xAxis = d3.svg.axis().scale(this.scaleX).tickSize(-6).tickSubdivide(true);
      $("#" + this.params.dimension + "-sort button").on("click", function() {
        return self._sortBy($(this).val());
      });
      this.svg = d3.select("#" + this.el).append("svg").attr("width", this.params.width).attr("height", this.params.height);
      this.svg.append("g").attr("class", "x axis").attr("transform", ("translate(" + this.params.margin.left + ",") + (this.params.height - 20) + ")").call(this.xAxis);
      this.tip = d3.tip().attr('class', 'd3-tip').offset((function(_this) {
        return function(d) {
          return [-30, _this.scaleX(d.median) - _this.params.margin.left - 18];
        };
      })(this)).html(function(d) {
        var html;
        html = "<div style='color:white; margin-bottom:10px;'>" + d.name + "'s air quality scores</div>\n<table class=\"table borderless\">\n  <tbody>\n    <tr>\n      <td>\n        <div>Low</div>\n        <div style=\"font-size:11px; color:#bbb;\">10th<br>percentile</div>\n      </td>\n      <td style=\"text-align:center;\">\n        <div>Median</div>\n      </td>\n      <td style=\"text-align:right;\">\n        <div>High</div>\n        <div style=\"font-size:11px; color:#bbb;\">90th<br>percentile</div></td>\n    </tr>\n    <tr style=\"font-size:26px;\">\n      <td class=\"" + (self.helpers.getColorClass(d.lower, self.qualitative)) + "\" style=\"color:white; text-align:center;\">\n        " + d.lower + "\n      </td>\n      <td class=\"" + (self.helpers.getColorClass(d.median, self.qualitative)) + "\" style=\"color:white; text-align:center;\">\n        " + d.median + "\n      </td>\n      <td class=\"" + (self.helpers.getColorClass(d.upper, self.qualitative)) + "\" style=\"color:white; text-align:center;\">\n        " + d.upper + "\n      </td>\n    </tr>\n  </tbody>\n</table>";
        return html;
      });
      this.svg.call(this.tip);
      this.chart = this.svg.append("g").attr("transform", "translate(" + this.params.margin.left + ", " + this.params.margin.top + ")");
      this.qualatativeTicks = this.chart.selectAll("line").data(this.qualitative).enter().append("g").attr("transform", (function(_this) {
        return function(d, i) {
          return "translate(" + (_this.scaleX(d.value)) + ", 0)";
        };
      })(this));
      this.qualatativeTicks.each(function(d, i) {
        var y2;
        y2 = self.params.height - (self.params.margin.top + self.params.margin.bottom) - 4;
        d3.select(this).append("line").attr("y1", -24).attr("y2", y2).attr("stroke-dasharray", "3,5").style("stroke-width", 1.5).attr("class", function(d) {
          return d["class"];
        });
        return d3.select(this).append("text").attr("text-anchor", "end").text(function(d) {
          return d.name;
        }).attr("x", -6).attr("y", -18).attr("class", function(d) {
          return d["class"];
        }).style("stroke", "none").style("font-size", "11");
      });
      this.chart.selectAll(".plot").data(this.data).enter().append("text").text(function(d, i) {
        return i + 1;
      }).attr("x", -this.params.margin.left + 4).attr("y", (function(_this) {
        return function(d, i) {
          return _this.scaleY(i) + 6;
        };
      })(this));
      this.plots = this.chart.selectAll(".plot").data(this.data).enter().append("g").attr("class", "plot").attr("transform", (function(_this) {
        return function(d, i) {
          return "translate(0, " + (_this.scaleY(i)) + ")";
        };
      })(this));
      this.plots.each(function(d, i) {
        if (self.city === d.name) {
          d3.select(this).append("rect").attr("width", 120).attr("height", 21).attr("x", function(d) {
            return -self.params.margin.left + 20;
          }).attr("y", -9).style("fill", "#333").style("stroke", "#333");
        }
        d3.select(this).append("text").text(d.name).attr("x", -self.params.margin.left + 32).attr("y", 6).attr("fill", function(d) {
          if (self.city === d.name) {
            return "white";
          } else {
            return "black";
          }
        });
        d3.select(this).append("rect").attr("width", function(d) {
          return self.scaleX(d.upper) - self.scaleX(d.lower);
        }).attr("height", 2).attr("x", function(d) {
          return self.scaleX(d.lower);
        }).style("fill", "#777");
        d3.select(this).append("rect").attr("class", function(d) {
          return "lower " + (self.helpers.getColorClass(d.lower, self.qualitative));
        }).style("fill", "white").attr("height", 15).attr("width", 5).attr("x", function(d) {
          return self.scaleX(d.lower);
        }).attr("y", function(d, i) {
          return self.scaleY(i) - 6;
        });
        d3.select(this).append("rect").attr("class", function(d) {
          return "median " + (self.helpers.getColorClass(d.median, self.qualitative));
        }).attr("height", 15).attr("width", 5).attr("x", function(d) {
          return self.scaleX(d.median);
        }).attr("y", function(d, i) {
          return self.scaleY(i) - 6;
        });
        d3.select(this).append("rect").attr("class", function(d) {
          return "upper " + (self.helpers.getColorClass(d.upper, self.qualitative));
        }).style("fill", "white").attr("height", 15).attr("width", 5).attr("x", function(d) {
          return self.scaleX(d.upper);
        }).attr("y", function(d, i) {
          return self.scaleY(i) - 6;
        });
        return d3.select(this).append("rect").style("fill", "#none").style("opacity", 0.0).attr("height", (self.params.height - (self.params.margin.top + self.params.margin.bottom)) / self.data.length).attr("width", self.params.width).attr("x", -self.params.margin.left).attr("y", function(d, i) {
          return self.scaleY(i) - 6;
        }).on('mouseover', self.tip.show).on('mouseout', self.tip.hide);
      });
    }

    BoxPlot.prototype._getScaleX = function() {
      var domainX, rangeX;
      domainX = this._getDomain(this.data);
      rangeX = [0, this.params.width - (this.params.margin.left + this.params.margin.right)];
      return this.params.scale().domain(domainX).range(rangeX);
    };

    BoxPlot.prototype._getScaleY = function() {
      var domainY, rangeY;
      domainY = [0, this.data.length];
      rangeY = [0, this.params.height - (this.params.margin.top + this.params.margin.bottom)];
      return d3.scale.linear().domain(domainY).range(rangeY);
    };

    BoxPlot.prototype._sortBy = function(dimension) {
      if (dimension == null) {
        dimension = 'median';
      }
      this.data = _.sortBy(this.data, dimension);
      return this.plots.data(this.data, function(d) {
        return d.name;
      }).transition().delay(function(d, i) {
        return i * 60;
      }).duration(230).ease("linear").attr("transform", (function(_this) {
        return function(d, i) {
          return "translate(0, " + (_this.scaleY(i)) + ")";
        };
      })(this));
    };

    BoxPlot.prototype._getDomain = function(data) {
      var max, min;
      max = _.max(_.pluck(data, "upper"));
      min = _.min(_.pluck(data, "lower"));
      return [min, max];
    };

    return BoxPlot;

  })(Chart);

  if (window.APP == null) {
    window.APP = {};
  }

  APP.charts = {
    BoxPlot: BoxPlot
  };

}).call(this);
