// Generated by CoffeeScript 1.9.0
(function() {
  var BoxPlot, Chart,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __hasProp = {}.hasOwnProperty;

  Chart = (function() {
    function Chart(_at_app, _at_params) {
      this.app = _at_app;
      this.params = _at_params;
    }

    return Chart;

  })();

  BoxPlot = (function(_super) {
    __extends(BoxPlot, _super);

    function BoxPlot(_at_app, _at_params, _at_data) {
      this.app = _at_app;
      this.params = _at_params;
      this.data = _at_data;
      this.el = this.params.el;
      this.svg = d3.select("#" + this.el).append("svg").attr("width", this.params.width).attr("height", this.params.height);
      this.data = this.sortBy(this.data, "median");
      this.svg.append("rect").attr("width", 100).attr("height", 100).style("fill", "red");
    }

    BoxPlot.prototype.sortBy = function(data, dimension) {
      if (dimension == null) {
        dimension = 'median';
      }
      return _.sortBy(data, dimension).reverse();
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