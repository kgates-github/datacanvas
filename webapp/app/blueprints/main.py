import json
from flask import Blueprint, render_template, request, jsonify
from app import models

main = Blueprint('main', __name__)


@main.route('/')
def index():
    return render_template('index.html', data={})


def get_data(date_from, date_to, name, time_of_day=''):
    df = models.load_cities_data(date_from, date_to, time_of_day)
    city_data = []
    for metric in ['airquality_raw', 'sound', 'dust', 'humidity', 'temperature', 'light', 'noise']:
        # Build Filter Results
        chart_data = {}
        chart_data['chart'] = 'filter'
        chart_data['dimension'] = 'none'
        chart_data['data'] = []
        data = models.get_metric_data(df, name, metric, date_from, date_to, 'hour')
        chart_data['data'].append(data)
        data = models.get_metric_data(df, name, metric, date_from, date_to, 'YearMonth')
        chart_data['data'].append(data)
        city_data.append(chart_data)

        # Build TimeSeries Results
        chart_data = models.get_ts_data(df, name, metric, date_from, date_to)
        city_data.append(chart_data)
        chart_data = models.get_city_agg_data(df, metric, date_from, date_to)
        city_data.append(chart_data)
    return city_data


@main.route('/city/<name>/')
@main.route('/city/')
def city(name='Shanghai'):
    date_from = '2015-01-01'
    date_to = '2015-03-31'
    data = get_data(date_from, date_to, name)
    return render_template('city.html', city=name, data=json.dumps(data))


@main.route('/update/')
def update():
    name = request.args.get('city', 'Shanghai')
    month = request.args.get('month', '')
    time_of_day = request.args.get('time_of_day', '')
    if month == 'Jan':
        date_from = '2015-01-01'
        date_to = '2015-01-31'
    elif month == 'Feb':
        date_from = '2015-02-01'
        date_to = '2015-02-28'
    elif month == 'Mar':
        date_from = '2015-03-01'
        date_to = '2015-03-31'
    else:
        date_from = '2015-01-01'
        date_to = '2015-03-31'
    data = get_data(date_from, date_to, name, time_of_day)
    return jsonify(data=data)
