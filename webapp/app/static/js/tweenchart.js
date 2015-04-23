// Generated by CoffeeScript 1.9.0
(function() {
  var TweenChart,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __hasProp = {}.hasOwnProperty;

  TweenChart = (function(_super) {
    __extends(TweenChart, _super);

    function TweenChart(_at_app, _at_params, _at_data, _at_helpers) {
      var city, cityData, data, date, self, _i, _len, _ref;
      this.app = _at_app;
      this.params = _at_params;
      this.data = _at_data;
      this.helpers = _at_helpers;
      self = this;
      this.el = this.params.el;
      this.qualitative = this.params.qualitative || [];
      this.columnChart = null;
      this.columnViewOpen = false;
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
      this.tip = d3.tip().attr('class', 'd3-tip-intro').offset((function(_this) {
        return function(d) {
          return [-40, 0];
        };
      })(this)).html(function(d) {
        var date, html;
        date = moment(d.timestamp);
        html = "<div>" + (date.format('ha MMMM DD')) + "</div>\n<div>Air quality score: <strong style=\"color:" + d.color + ";\">" + d.score + "</strong></div>";
        return html;
      });
      this.svg.call(this.tip);
      this.filter = this.svg.append("defs");
      this.filter.append("filter").attr("id", "blur").append("feGaussianBlur").attr("stdDeviation", 7);
      this.filter.append("filter").attr("id", "blurMore").append("feGaussianBlur").attr("stdDeviation", 20);
      this.filter.append("filter").attr("id", "unblur").append("feGaussianBlur").attr("stdDeviation", 0);
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
      this.mainContainer = this.svg.append("g");
      this.cityTranslate = {};
      this.cityContainers = this.mainContainer.selectAll("g").data(this.cityData).enter().append("g").attr("transform", (function(_this) {
        return function(d, i) {
          _this.cityTranslate[d.city] = "translate(" + (i % 2 * 85 + 0) + ", " + (60 + i * 70) + ")";
          return _this.cityTranslate[d.city];
        };
      })(this)).attr("id", function(d, i) {
        return "id-" + i;
      }).attr("class", "city").attr("filter", function(d) {
        return "url(#blur)";
      });
      this.cityContainers.each(function(d, i) {
        var containerIndex;
        containerIndex = i;
        this.day = d3.select(this).selectAll(".day").data(d.data).enter().append("g").attr("class", "day").attr("transform", function(d, i) {
          return "translate(" + (50 + i * 190) + ", 0)";
        });
        this.day.each(function(d, i) {
          return this.path = d3.select(this).selectAll(".middleSolidArc").data(self.pie(d)).enter().append("path").attr("fill", function(d) {
            if (d.data.score > 0) {
              return d.data.color;
            }
            return "none";
          }).style("opacity", 1.0).attr("class", "middleSolidArc").attr("stroke", "#fff").attr("stroke-width", 1.5).attr("d", self.arc);
        });
        this.day.each(function(d, i) {
          var index, score;
          date = moment(d[0].timestamp);
          index = containerIndex;
          score = d3.select(this).append("g").attr("class", "dayText").attr("opacity", 0);
          score.attr("transform", function(d, i) {
            if (index === 4) {
              return "translate(0, -48)";
            } else if (index === 5) {
              return "translate(0, -48)";
            }
            return "translate(0, 70)";
          });
          return score.append("text").attr("class", "radial-date").style("fill", "#999").attr("y", 0).attr("text-anchor", "middle").text(date.format('MMMM DD'));
        });
        return d3.select(this).style("cursor", "pointer").on("click", (function(_this) {
          return function(e) {
            if (!self.columnViewOpen) {
              return self.tweenToColumns(_this);
            }
          };
        })(this));
      });
      this.svg.selectAll(".city").append("rect").attr("y", -this.params.height / 14).attr("width", this.params.width).attr("height", this.params.height / 6).style("opacity", 0.0).on("mouseover", (function(_this) {
        return function(d, i) {
          if (!_this.columnViewOpen) {
            return self.unBlurCity("id-" + i, i, d);
          }
        };
      })(this)).style("cursor", "pointer");
      this.svg.on("mouseout", (function(_this) {
        return function() {
          if (!_this.columnViewOpen) {
            return _this.resetBlur();
          }
        };
      })(this));
    }

    TweenChart.prototype.createColumns = function(elem) {
      var container, data, g, scaleY, self;
      self = this;
      scaleY = d3.scale.linear().domain([0, 380]).range([0, 200]);
      data = elem.__data__.data;
      g = d3.select(elem);
      container = this.svg.append("g").attr("transform", g.attr("transform"));
      data.forEach(function(dayData, i) {
        var bars, day;
        day = container.append("g").attr("class", "columnGroup").attr("transform", "translate(" + (50 + i * 190) + ", 0)");
        bars = day.selectAll(".bar").data(dayData).enter().append("rect").attr("class", "bar").attr("width", 0).attr("height", (function(_this) {
          return function(d) {
            return scaleY(d.score);
          };
        })(this)).style("stroke", "none").style("fill", function(d) {
          return d.color;
        }).attr("x", 0).attr("y", function(d) {
          return 20 - scaleY(d.score);
        });
        return day.selectAll("overlay").data(dayData).enter().append("rect").attr("x", function(d, i) {
          return -50 + i * 7.9;
        }).attr("y", -50).attr("width", 10).attr("height", 100).attr("opacity", 0).on('mouseover', self.tip.show).on('mouseout', self.tip.hide);
      });
      return container;
    };

    TweenChart.prototype.openColumns = function(columnChart, elem) {
      var city, self;
      self = this;
      columnChart.attr("transform", "translate(0, 248)");
      city = elem.__data__.data[0][0].label;
      d3.select("#intro-button").on("click", function() {
        return window.location.href = "/city/" + city + "/";
      });
      d3.select("#intro-close").on("click", function() {
        return self.tweenToRadial(columnChart, elem);
      });
      d3.select("#intro-text-city").html(city);
      return columnChart.selectAll("g").selectAll(".bar").transition().duration(700).attr("width", 4).attr("x", function(d, i) {
        return -50 + i * 7.9;
      }).each("end", (function(_this) {
        return function(d, i) {
          if (i === 0) {
            return $(".intro").show();
          }
        };
      })(this));
    };

    TweenChart.prototype.tweenToColumns = function(elem) {
      var arcTween, self;
      self = this;
      this.columnViewOpen = true;
      arcTween = function(transition, newStartAngle, newEndAngle) {
        return transition.attrTween("d", function(d) {
          var interpolateEnd, interpolatestart;
          interpolateEnd = d3.interpolate(d.endAngle, newEndAngle);
          interpolatestart = d3.interpolate(d.startAngle, newStartAngle);
          return function(t) {
            d.startAngle = interpolateEnd(t);
            d.endAngle = interpolatestart(t);
            return self.arc(d);
          };
        });
      };
      this.columnViewOpen = true;
      d3.select("#intro-text").transition().duration(750).style("top", "230px");
      return d3.select(elem).transition().duration(750).attr("transform", "translate(0, 248)").each("end", (function(_this) {
        return function(d, i) {
          _this.columnChart = _this.createColumns(elem);
          return d3.select(elem).selectAll(".middleSolidArc").transition().duration(750).call(arcTween, 0, 0).each("end", function(d, i) {
            if (i === 0) {
              return _this.openColumns(_this.columnChart, elem);
            }
          });
        };
      })(this));
    };

    TweenChart.prototype.tweenToRadial = function(columnChart, elem) {
      var arcTween, called, self;
      self = this;
      arcTween = function(transition, newStartAngle, newEndAngle) {
        return transition.attrTween("d", function(d) {
          var interpolateEnd, interpolatestart;
          interpolateEnd = d3.interpolate(d.endAngle, newEndAngle);
          interpolatestart = d3.interpolate(d.startAngle, newStartAngle);
          return function(t) {
            d.startAngle = interpolateEnd(t);
            d.endAngle = interpolatestart(t);
            return self.arc(d);
          };
        });
      };
      $(".intro").hide();
      called = false;
      return d3.selectAll(".columnGroup").selectAll("rect").transition().duration(700).attr("x", 0).each("end", (function(_this) {
        return function(d, i) {
          var called2, city, data, days;
          if (i === 0 && !called) {
            called = true;
            d3.selectAll(".columnGroup").remove();
            city = elem.__data__.city;
            data = _.findWhere(_this.cityData, {
              "city": city
            }).data;
            days = d3.select(elem).selectAll(".day");
            d3.select(elem).attr("filter", "url(#unblur)");
            called2 = false;
            return days.each(function(d, i) {
              var d1, radials;
              radials = d3.select(this).selectAll(".middleSolidArc");
              d1 = self.pie(data[i]);
              return radials.each(function(d, i) {
                return d3.select(this).transition().duration(750).call(arcTween, d1[i].startAngle, d1[i].endAngle).each("end", (function(_this) {
                  return function(d, i) {
                    if (i === 0 && !called2) {
                      called2 = true;
                      return d3.select(elem).attr("filter", "url(#unblur)").transition().duration(550).attr("transform", self.cityTranslate[city]).each("end", function(d, i) {
                        if (i === 0) {
                          return self.columnViewOpen = false;
                        }
                      });
                    }
                  };
                })(this));
              });
            });
          }
        };
      })(this));
    };

    TweenChart.prototype.resetBlur = function() {
      if (!this.columnViewOpen) {
        $("#intro-text").hide();
      }
      d3.selectAll(".city").attr("filter", (function(_this) {
        return function(d) {
          return "url(#blur)";
        };
      })(this)).attr("opacity", 1);
      return d3.selectAll(".day .dayText").style("opacity", 0);
    };

    TweenChart.prototype.unBlurCity = function(idx, index, d) {
      if (d.city === 'Bangalore' || d.city === 'Boston') {
        $("#intro-text").css({
          "top": "370px"
        });
      } else {
        $("#intro-text").css({
          "top": "230px"
        });
      }
      $("#intro-text").show();
      d3.select("#intro-text-city").html(d.city);
      d3.selectAll(".city").attr("filter", function(d) {
        return "url(#blur)";
      }).attr("opacity", 0.3);
      d3.selectAll("#" + idx).attr("filter", (function(_this) {
        return function(d) {
          return "url(#unblur)";
        };
      })(this)).selectAll("text").style("opacity", 1);
      d3.selectAll("#" + idx + " .dayText").style("opacity", 1);
      return d3.selectAll("#" + idx).attr("opacity", 1.0);
    };

    TweenChart.prototype.blurCities = function() {
      console.log("un");
      return d3.selectAll(".cityText text").style("opacity", 0);
    };

    return TweenChart;

  })(APP.charts['Chart']);

  APP.charts['TweenChart'] = TweenChart;

}).call(this);
