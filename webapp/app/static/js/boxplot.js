// Generated by CoffeeScript 1.9.0
(function() {
  var BoxPlot,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __hasProp = {}.hasOwnProperty;

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
      this.qualitative = this.params.qualitative || [];
      this.scaleX = this._getScaleX();
      this.scaleY = this._getScaleY();
      this.xAxis = d3.svg.axis().scale(this.scaleX).tickSize(-this.params.height).tickSubdivide(true);
      $("#" + this.params.dimension + "-sort").hide();
      $("#" + this.params.dimension + "-sort button").on("click", function() {
        self._sortBy($(this).val());
        return self._toggleButtons($(this).val());
      });
      this.svg = d3.select("#" + this.el).append("svg").attr("width", this.params.width).attr("height", this.params.height);
      this.svg.append("g").attr("class", "x axis boxplot").attr("transform", ("translate(" + this.params.margin.left + ",") + (this.params.height - 30) + ")").call(this.xAxis);
      this.tip = d3.tip().attr('class', 'd3-tip').offset((function(_this) {
        return function(d) {
          return [-20, _this.scaleX(d.median) - _this.params.margin.left - 18];
        };
      })(this)).html(function(d) {
        var html, lowerClass, lowerName, medianClass, medianName, upperClass, upperName;
        lowerClass = self.helpers.getColorClass(d.min, self.qualitative);
        lowerName = _.findWhere(self.qualitative, {
          "class": lowerClass
        }).name;
        medianClass = self.helpers.getColorClass(d.median, self.qualitative);
        medianName = _.findWhere(self.qualitative, {
          "class": medianClass
        }).name;
        upperClass = self.helpers.getColorClass(d.max, self.qualitative);
        upperName = _.findWhere(self.qualitative, {
          "class": upperClass
        }).name;
        html = "<div style='font-size:11px; color:#bbb; margin-bottom:0px;'>" + d.city + "'s Air Quality Index</div>\n<table class=\"table borderless\">\n  <tbody>\n    <tr>\n      <td>\n        <div>Min</div>\n        \n      </td>\n      <td style=\"text-align:center;\">\n        <div>Average</div>\n      </td>\n      <td style=\"text-align:right;\">\n        <div>Max</div>\n        \n    </tr>\n    <tr style=\"font-size:26px;\">\n      <td class=\"" + lowerClass + "-score\" style=\"width:70px; text-align:left;\">\n        " + (d3.round(d.lower, self.params.round)) + "\n        <div style=\"font-size:11px; \">" + lowerName + "</div></td>\n      </td>\n      <td class=\"" + medianClass + "-score\" style=\"width:70px; text-align:center;\">\n        " + (d3.round(d.median, self.params.round)) + "\n        <div style=\"font-size:11px; \">" + medianName + "</div></td>\n      </td>\n      <td class=\"" + upperClass + "-score\" style=\"width:70px; text-align:right;\">\n        " + (d3.round(d.max, self.params.round)) + "\n        <div style=\"font-size:11px; \">" + upperName + "</div></td>\n      </td>\n    </tr>\n  </tbody>\n</table>";
        return html;
      });
      this.svg.call(this.tip);
      this.chart = this.svg.append("g").attr("transform", "translate(" + this.params.margin.left + ", " + (this.params.margin.top + 10) + ")");
      this.qualatativeTicks = this.chart.selectAll(".qualitative").data(this.qualitative).enter().append("g").attr("class", "qualitative").attr("transform", (function(_this) {
        return function(d, i) {
          return "translate(" + (_this.scaleX(d.value)) + ", 0)";
        };
      })(this));
      this.qualatativeTicks.each(function(d, i) {
        var x2, y2;
        y2 = self.params.height - (self.params.margin.top + self.params.margin.bottom) - 4;
        x2 = d.name === 'Good' ? self.scaleX(d.value - self.domainX[0] + 1) - 5 : self.scaleX(d.value - d.lower + 1) - 5;
        d3.select(this).append("line").attr("y1", -44).attr("y2", y2).attr("stroke-dasharray", "3,5").style("stroke-width", 2.5).attr("class", function(d) {
          return d["class"];
        });
        d3.select(this).append("line").attr("y1", -30).attr("y2", -30).attr("x1", 0).attr("x2", -x2).style("stroke-width", 5.0).attr("class", function(d) {
          return d["class"];
        });
        return d3.select(this).append("text").attr("text-anchor", "end").text(function(d) {
          return d.name;
        }).attr("x", -6).attr("y", -14).attr("class", function(d) {
          return d["class"];
        }).style("stroke", "none").style("font-size", "11");
      });
      this.chart.append("text").attr("class", "x label").style("fill", "#999").style("font-weight", "400").attr("text-anchor", "end").attr("x", -10).attr("y", this.params.height - 60).text(this.params.xAxisLabel);
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
        if (self.city === d.city) {
          d3.select(this).append("rect").attr("width", 120).attr("height", 21).attr("x", function(d) {
            return -self.params.margin.left + 20;
          }).attr("y", -9).style("fill", "#333").style("stroke", "#333");
        }
        d3.select(this).append("text").text(d.city).attr("x", -self.params.margin.left + 32).attr("y", 6).attr("fill", function(d) {
          if (self.city === d.city) {
            return "white";
          } else {
            return "black";
          }
        });
        d3.select(this).append("rect").attr("width", function(d) {
          return self.scaleX(d.max) - self.scaleX(d.min);
        }).attr("height", 1).attr("class", "bar").attr("x", function(d) {
          return self.scaleX(d.min);
        }).attr("y", function(d, i) {
          return self.scaleY(i) + 1;
        }).style("fill", "#666");
        d3.select(this).append("rect").attr("class", function(d) {
          return "min";
        }).attr("height", 15).attr("width", 1).style("fill", "#666").attr("x", function(d) {
          return self.scaleX(d.min);
        }).attr("y", function(d, i) {
          return self.scaleY(i) - 6;
        });

        /*
        d3.select(@).append("rect")
          #.attr("class", (d) -> "median #{self.helpers.getColorClass(d.median, self.qualitative)}")
          .attr("class", (d) -> "median")
          .attr("height", 15)
          .attr("width", 6)
          .style("fill", "#666")
          .attr("x", (d) -> self.scaleX(d.median) - 3)
          .attr("y", (d, i) -> self.scaleY(i) - 6)
         */
        d3.select(this).append("circle").attr("class", function(d) {
          return "median";
        }).attr("r", 5).style("fill", "#666").attr("cx", function(d) {
          return self.scaleX(d.median);
        }).attr("cy", function(d, i) {
          return self.scaleY(i) + 1.5;
        });
        d3.select(this).append("rect").attr("class", function(d) {
          return "max";
        }).attr("height", 15).attr("width", 1).style("fill", "#666").attr("x", function(d) {
          return self.scaleX(d.max);
        }).attr("y", function(d, i) {
          return self.scaleY(i) - 6;
        });
        return d3.select(this).append("rect").style("fill", "#none").style("opacity", 0.0).attr("class", "overlay").attr("height", (self.params.height - (self.params.margin.top + self.params.margin.bottom)) / self.data.length).attr("width", self.params.width).attr("x", -self.params.margin.left).attr("y", function(d, i) {
          return self.scaleY(i) - 6;
        }).on('mouseover', self.tip.show).on('mouseout', self.tip.hide);
      });
      this._setExplanationText();
    }

    BoxPlot.prototype._toggleButtons = function(idx) {
      d3.selectAll("#" + this.params.dimension + "-sort button").classed({
        'on': false
      });
      return d3.select("#" + idx).classed({
        'on': true
      });
    };

    BoxPlot.prototype._getScaleX = function() {
      var rangeX;
      this.domainX = this._getDomain(this.data);
      rangeX = [0, this.params.width - (this.params.margin.left + this.params.margin.right)];
      return this.params.scale().domain(this.domainX).range(rangeX);
    };

    BoxPlot.prototype._getScaleY = function() {
      var domainY, rangeY;
      domainY = [0, this.data.length];
      rangeY = [0, this.params.height - (this.params.margin.top + this.params.margin.bottom)];
      return d3.scale.linear().domain(domainY).range(rangeY);
    };

    BoxPlot.prototype._sortBy = function(dimension, delay) {
      if (dimension == null) {
        dimension = 'median';
      }
      if (delay == null) {
        delay = 0;
      }
      this.data = _.sortBy(this.data, dimension);
      return this.plots.data(this.data, function(d) {
        return d.city;
      }).transition().delay(function(d, i) {
        return (i * 160) + delay;
      }).duration(330).ease("linear").attr("transform", (function(_this) {
        return function(d, i) {
          return "translate(0, " + (_this.scaleY(i)) + ")";
        };
      })(this));
    };

    BoxPlot.prototype._getDomain = function(data) {
      var elem, max, min, _i, _len, _ref;
      max = _.max(_.pluck(data, "max"));
      min = _.min(_.pluck(data, "min"));
      if (this.qualitative.length) {
        _ref = this.qualitative;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          elem = _ref[_i];
          if (max < elem.value) {
            max = elem.value;
            break;
          }
        }
      }
      if (max < 55) {
        max = 55;
      }
      return [min, max];
    };

    BoxPlot.prototype.update = function(data) {
      var city, duration, i, newDatum, self;
      self = this;
      for (i in this.data) {
        city = this.data[i].city;
        newDatum = _.find(data, function(d) {
          return d.city === city;
        });
        if (newDatum != null) {
          this.data[i] = newDatum;
        }
      }
      this.scaleX = this._getScaleX();
      duration = this._getDuration();
      this.plots.data(this.data, function(d) {
        return d.city;
      });
      this.plots.each(function(d, i) {
        d3.select(this).select(".bar").transition().duration(duration).attr("width", function(d) {
          return self.scaleX(d.max) - self.scaleX(d.min);
        }).attr("x", function(d) {
          return self.scaleX(d.min);
        });
        d3.select(this).select(".min").transition().duration(duration).attr("x", function(d) {
          return self.scaleX(d.min);
        });
        d3.select(this).select(".median").transition().duration(duration).attr("cx", function(d) {
          return self.scaleX(d.median);
        });
        d3.select(this).select(".max").transition().duration(duration).attr("x", function(d) {
          return self.scaleX(d.max);
        });
        return d3.select(this).select(".overlay").on('mouseover', self.tip.show).on('mouseout', self.tip.hide);
      });
      this.qualatativeTicks.each(function(d, i) {
        return d3.select(this).transition().duration(duration).attr("transform", (function(_this) {
          return function(d, i) {
            return "translate(" + (self.scaleX(d.value)) + ", 0)";
          };
        })(this));
      });
      this.xAxis = d3.svg.axis().scale(this.scaleX).tickSize(-this.params.height).tickSubdivide(true);
      this.svg.selectAll("g.x.axis").transition().duration(1000).call(this.xAxis);
      this._sortBy('median', 1000);
      return this._setExplanationText();
    };

    BoxPlot.prototype._setExplanationText = function() {
      var html, monthText, timeOfDayText;
      this.filters = this.app.getFilters();
      monthText = this.filters.monthFilter ? this.filters.monthFilter + ", 2015" : "between " + this.filters.startMonth + " and " + this.filters.endMonth + ", 2015";
      timeOfDayText = this.filters.timeOfDayFilter != null ? " and <strong>only use data collected between " + this.filters.timeOfDayFilter + "</strong>" : "";
      html = "Measurements are from " + monthText + timeOfDayText + ".";
      return d3.select("#rank-explanation").html(html);
    };

    return BoxPlot;

  })(APP.charts['Chart']);

  APP.charts['BoxPlot'] = BoxPlot;

}).call(this);
