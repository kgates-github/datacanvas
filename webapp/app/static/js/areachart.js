// Generated by CoffeeScript 1.9.0
(function() {
  var AreaChart,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __hasProp = {}.hasOwnProperty;

  AreaChart = (function(_super) {
    __extends(AreaChart, _super);

    function AreaChart(_at_app, _at_params, _at_data, _at_city, _at_helpers) {
      this.app = _at_app;
      this.params = _at_params;
      this.data = _at_data;
      this.city = _at_city;
      this.helpers = _at_helpers;
      null;
    }

    return AreaChart;

  })(APP.charts['Chart']);

  APP.charts['AreaChart'] = AreaChart;

}).call(this);
