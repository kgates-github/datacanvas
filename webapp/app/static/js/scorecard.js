// Generated by CoffeeScript 1.9.0
(function() {
  var ScoreCard,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __hasProp = {}.hasOwnProperty;

  ScoreCard = (function(_super) {
    __extends(ScoreCard, _super);

    function ScoreCard(_at_app, _at_params, _at_data, _at_city, _at_helpers) {
      this.app = _at_app;
      this.params = _at_params;
      this.data = _at_data;
      this.city = _at_city;
      this.helpers = _at_helpers;
      this._setHTML();
    }

    ScoreCard.prototype._setHTML = function() {
      var good, hazardous, html, moderate, unhealthy, unhealthyMild, unhealthyVery;
      good = _.filter(this.data, function(d) {
        return d.max <= 50;
      });
      moderate = _.filter(this.data, function(d) {
        return d.max > 50 && d.max <= 100;
      });
      unhealthyMild = _.filter(this.data, function(d) {
        return d.max > 100 && d.max <= 150;
      });
      unhealthy = _.filter(this.data, function(d) {
        return d.max > 150 && d.max <= 200;
      });
      unhealthyVery = _.filter(this.data, function(d) {
        return d.max > 200 && d.max <= 300;
      });
      hazardous = _.filter(this.data, function(d) {
        return d.max > 300;
      });
      html = "<table id=\"score-card\" style=\"width:100%; font-size:11px;\">\n    <tr class=\"scores\">\n      <td class=\"good-score\">\n        " + good.length + "\n        <div style=\"font-size:11px;\">Good</div>\n      </td>\n      <td class=\"moderate-score\">\n        " + moderate.length + "\n        <div style=\"font-size:11px;\">Moderate</div>\n      </td>\n      <td class=\"unhealthy-mild-score\">\n        " + unhealthyMild.length + "\n        <div style=\"font-size:11px; line-height:12px;\">Mildly unhealthy</div>\n      </td>\n      <td class=\"unhealthy-score\">\n        " + unhealthy.length + "\n        <div style=\"font-size:11px;\">Unhealthy</div>\n      </td>\n      <td class=\"unhealthy-very-score\">\n        " + unhealthyVery.length + "\n        <div style=\"font-size:11px;\">Very unhealthy</div>\n      </td>\n       <td class=\"hazardous-score\">\n        " + hazardous.length + "\n        <div style=\"font-size:11px;\">Hazardous</div>\n      </td>\n    </tr>\n    <tr class='score-text'>\n      <td>\n        Days highest AQI remained lower than 50\n      </td>\n      <td>\n        Days highest AQI reach moderately unhealthy levels\n      </td>\n      <td>\n        Days AQI reached mildly unhealthy levels\n      </td>\n      <td>\n        Days AQI reached unhealthy levels\n      </td>\n      <td>\n        Days AQI reached very unhealthy levels\n      </td>\n       <td>\n        Days AQI reached hazardous levels\n      </td>\n    </tr>\n  </table>";
      return d3.select("#" + this.params.el).html(html);
    };

    ScoreCard.prototype.update = function(data) {
      var self;
      self = this;
      this.data = data;
      return this._setHTML();
    };

    return ScoreCard;

  })(APP.charts['Chart']);

  APP.charts['ScoreCard'] = ScoreCard;

}).call(this);
